/*
 *  Phusion Passenger - http://www.modrails.com/
 *  Copyright (c) 2010 Phusion
 *
 *  "Phusion Passenger" is a trademark of Hongli Lai & Ninh Bui.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <cstring>
#include <cassert>
#include <cerrno>
#include <unistd.h>
#include <limits.h>
#include <pwd.h>
#include <grp.h>

#include <set>
#include <vector>
#include <string>

#include <boost/thread.hpp>
#include <boost/shared_ptr.hpp>
#include "oxt/thread.hpp"
#include "oxt/system_calls.hpp"

#include "ScgiRequestParser.h"

#include "AgentBase.h"
#include "HelperAgent/BacktracesServer.h"
#include "Constants.h"
#include "ApplicationPool/Pool.h"
#include "ApplicationPool/Server.h"
#include "Session.h"
#include "PoolOptions.h"
#include "MessageServer.h"
#include "FileDescriptor.h"
#include "ResourceLocator.h"
#include "ServerInstanceDir.h"
#include "Exceptions.h"
#include "Utils.h"
#include "Utils/Timer.h"
#include <Utils/IOUtils.h>
#include <Utils/MessageIO.h>
#include <Utils/Dechunker.h>
#include <Utils/HttpHeaderBufferer.h>
#include <Utils/StreamBoyerMooreHorspool.h>

using namespace boost;
using namespace oxt;
using namespace Passenger;

#define REQUEST_SOCKET_PASSWORD_SIZE     64

static StreamBMH_Occ statusFinder_occ;
static StreamBMH_Occ transferEncodingFinder_occ;

struct ClientDisconnectedException { };

class ExitHandler: public MessageServer::Handler {
private:
	EventFd &exitEvent;
	
public:
	ExitHandler(EventFd &_exitEvent)
		: exitEvent(_exitEvent)
	{ }
	
	virtual bool processMessage(MessageServer::CommonClientContext &commonContext,
	                            MessageServer::ClientContextPtr &handlerSpecificContext,
	                            const vector<string> &args)
	{
		if (args[0] == "exit") {
			TRACE_POINT();
			commonContext.requireRights(Account::EXIT);
			UPDATE_TRACE_POINT();
			exitEvent.notify();
			UPDATE_TRACE_POINT();
			commonContext.channel.write("exit command received", NULL);
			return true;
		} else {
			return false;
		}
	}
};

/**
 * A representation of a Client from the Server's point of view. This class
 * contains the methods used to communicate from a server to a connected
 * client, i.e. it is a client handler.
 * These Client instances will communicate concurrently with the server through
 * threads. Considering the overhead of these threads, i.e. setup and teardown
 * costs and the volatility of client requests, these client instances will be
 * pooled. It is for this reason that the State design pattern has been applied:
 * this class can be considered as being a skeleton implemention whose state
 * --e.g. the client file descriptor-- needs to be provided in order to function
 * properly.
 */
class Client {
private:
	/** Maximum allowed size of SCGI headers. */
	static const unsigned int MAX_HEADER_SIZE = 1024 * 128;
	/** The client thread stack size in bytes. */
	static const int CLIENT_THREAD_STACK_SIZE =
		// Give a small amount of normal stack space
		#ifdef __FreeBSD__
			// localtime() on FreeBSD needs some more stack space.
			1024 * 96
		#else
			1024 * 64
		#endif
		// and some more stack space for storing the session header.
		+ MAX_HEADER_SIZE + 1024;
	
	/** The client number for this Client object, assigned by Server. */
	unsigned int number;
	
	/** The application pool to which this Client object belongs to. */
	ApplicationPool::Ptr pool;
	
	/** This client's password. */
	string password;
	
	string defaultUser;
	string defaultGroup;
	
	/** The server socket file descriptor. */
	int serverSocket;
	
	/** The analytics logger to use. */
	AnalyticsLoggerPtr analyticsLogger;
	
	/** This client's thread. */
	oxt::thread *thr;
	
	/** A timer for measuring how long this worker thread has been doing
	 * nothing (i.e. waiting for a connection).
	 */
	Timer inactivityTimer;
	
	int currentClient;
	HttpHeaderBufferer headerBufferer;
	union {
		struct StreamBMH ctx;
		char padding[SBMH_SIZE(sizeof("Status:") - 1)];
	} statusFinder;
	union {
		struct StreamBMH ctx;
		char padding[SBMH_SIZE(sizeof("Transfer-Encoding:") - 1)];
	} transferEncodingFinder;
	
	/** Given a substring containing the start of the header value,
	 * extracts the substring that contains a single header value.
	 *
	 *   const char *data =
	 *      "Status: 200 OK\r\n"
	 *      "Foo: bar\r\n";
	 *   extractHeaderValue(data + strlen("Status:"), strlen(data) - strlen("Status:"));
	 *      // "200 OK"
	 */
	static StaticString extractHeaderValue(const char *data, size_t size) {
		const char *start = data;
		const char *end   = data + size;
		const char *terminator;
		
		while (start < end && *start == ' ') {
			start++;
		}
		
		terminator = (const char *) memchr(start, '\r', end - start);
		if (terminator == NULL) {
			return StaticString();
		} else {
			return StaticString(start, terminator - start);
		}
	}
	
	StaticString extractAndSanitizeHttpStatus(const StaticString &header, char buf[32]) {
		StaticString status;
		size_t accepted;
		
		sbmh_reset(&statusFinder.ctx);
		accepted = sbmh_feed(&statusFinder.ctx,
			&statusFinder_occ,
			(const unsigned char *) "Status:",
			sizeof("Status:") - 1,
			(const unsigned char *) header.data(),
			header.size());
		if (statusFinder.ctx.found) {
			status = extractHeaderValue(header.data() + accepted,
				header.size() - accepted);
			if (status.find(' ') == string::npos) {
				int code = stringToInt(status);
				switch (code) {
				case 100:
					status = "100 Continue";
					break;
				case 101:
					status = "101 Switching Protocols";
					break;
				case 102:
					status = "102 Processing";
					break;
				case 200:
					status = "200 OK";
					break;
				case 201:
					status = "201 Created";
					break;
				case 202:
					status = "202 Accepted";
					break;
				case 203:
					status = "203 Non-Authoritative Information";
					break;
				case 204:
					status = "204 No Content";
					break;
				case 205:
					status = "205 Reset Content";
					break;
				case 206:
					status = "206 Partial Content";
					break;
				case 207:
					status = "207 Multi-Status";
					break;
				case 300:
					status = "300 Multiple Choices";
					break;
				case 301:
					status = "301 Moved Permanently";
					break;
				case 302:
					status = "302 Found";
					break;
				case 303:
					status = "303 See Other";
					break;
				case 304:
					status = "304 Not Modified";
					break;
				case 305:
					status = "305 Use Proxy";
					break;
				case 306:
					status = "306 Switch Proxy";
					break;
				case 307:
					status = "307 Temporary Redirect";
					break;
				case 308:
					// Google Gears: http://code.google.com/p/gears/wiki/ResumableHttpRequestsProposal
					status = "308 Resume Incomplete";
					break;
				case 400:
					status = "400 Bad Request";
					break;
				case 401:
					status = "401 Unauthorized";
					break;
				case 402:
					status = "402 Payment Required";
					break;
				case 403:
					status = "403 Forbidden";
					break;
				case 404:
					status = "404 Not Found";
					break;
				case 405:
					status = "405 Method Not Allowed";
					break;
				case 406:
					status = "406 Not Acceptable";
					break;
				case 407:
					status = "407 Proxy Authentication Required";
					break;
				case 408:
					status = "408 Request Timeout";
					break;
				case 409:
					status = "409 Conflict";
					break;
				case 410:
					status = "410 Gone";
					break;
				case 411:
					status = "411 Length Required";
					break;
				case 412:
					status = "412 Precondition Failed";
					break;
				case 413:
					status = "413 Request Entity Too Large";
					break;
				case 414:
					status = "414 Request-URI Too Long";
					break;
				case 415:
					status = "415 Unsupported Media Type";
					break;
				case 416:
					status = "416 Requested Range Not Satisfiable";
					break;
				case 417:
					status = "417 Expectation Failed";
					break;
				case 418:
					status = "418 Not A Funny April Fools Joke";
					break;
				case 422:
					status = "422 Unprocessable Entity";
					break;
				case 423:
					status = "423 Locked";
					break;
				case 424:
					status = "424 Unordered Collection";
					break;
				case 426:
					status = "426 Upgrade Required";
					break;
				case 449:
					status = "449 Retry With";
					break;
				case 450:
					status = "450 Blocked";
					break;
				case 500:
					status = "500 Internal Server Error";
					break;
				case 501:
					status = "501 Not Implemented";
					break;
				case 502:
					status = "502 Bad Gateway";
					break;
				case 503:
					status = "503 Service Unavailable";
					break;
				case 504:
					status = "504 Gateway Timeout";
					break;
				case 505:
					status = "505 HTTP Version Not Supported";
					break;
				case 506:
					status = "506 Variant Also Negotiates";
					break;
				case 507:
					status = "507 Insufficient Storage";
					break;
				case 509:
					status = "509 Bandwidth Limit Exceeded";
					break;
				case 510:
					status = "510 Not Extended";
					break;
				default:
					snprintf(buf, 32,
						"%d Unknown Status Code",
						code);
					buf[31] = '\0';
					status = buf;
				}
			}
		} else {
			status = "200 OK";
		}
		
		return status;
	}
	
	bool detectChunkedTransferEncodingAndRemoveHeader(const StaticString &header) {
		size_t accepted;
		
		sbmh_reset(&transferEncodingFinder.ctx);
		accepted = sbmh_feed(&transferEncodingFinder.ctx,
			&transferEncodingFinder_occ,
			(const unsigned char *) "Transfer-Encoding:",
			sizeof("Transfer-Encoding:") - 1,
			(const unsigned char *) header.data(),
			header.size());
		if (transferEncodingFinder.ctx.found) {
			StaticString value = extractHeaderValue(header.data() + accepted,
				header.size() - accepted);
			if (value == "chunked") {
				// Remove Transfer-Encoding header.
				char *tmp = (char *) (header.data() + accepted - 2);
				*tmp = '_';
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	/**
	 * Attempts to accept a connection made by the client.
	 *
	 * @return The file descriptor corresponding to the accepted connection.
	 * @throws SystemException Could not accept new connection.
	 */
	FileDescriptor acceptConnection() {
		TRACE_POINT();
		struct sockaddr_un addr;
		socklen_t addrlen = sizeof(addr);
		int fd = syscalls::accept(serverSocket,
			(struct sockaddr *) &addr,
			&addrlen);
		if (fd == -1) {
			throw SystemException("Cannot accept new connection", errno);
		} else {
			return FileDescriptor(fd);
		}
	}
	
	/**
	 * Reads and checks the password of a client message channel identified by the given file descriptor.
	 * The HelperAgent makes extensive use of Unix Sockets that would normally allow other processes to
	 * connect to it as well. In our case, we just want to limit this to Nginx and it is for this reason
	 * that we've secured communication channels between this server and its clients with passwords.
	 * This method indicates whether or not the password of this client channel matches the one known to
	 * the server.
	 * 
	 * @param fd The file descriptor identifying the client message channel.
	 * @return True if the password of the client channel indicated by the given file descriptor
	 *   matches the password known to the server. False will be returned if either the
	 *   passwords don't match or EOF has been encountered.
	 */
	bool readAndCheckPassword(FileDescriptor &fd) {
		TRACE_POINT();
		char buf[REQUEST_SOCKET_PASSWORD_SIZE];
		
		if (readExact(fd, buf, sizeof(buf)) == sizeof(buf)) {
			const char *password_data;
			
			password_data = const_cast<const string &>(password).c_str();
			return memcmp(password_data, buf, sizeof(buf)) == 0;
		} else {
			return false;
		}
	}
	
	/**
	 * Reads and parses the request headers from the given file descriptor with the given SCGI request parser
	 * and if succesful, assigns the remainder of the request (i.e. non SCGI header data) to the given 
	 * requestBody.
	 *
	 * @param fd The file descriptor to read and parse from.
	 * @param parser The ScgiRequestParser to use for parsing the SCGI headers.
	 * @param requestBody The requestBody that was extracted as a result from parsing the SCGI headers.
	 * @return True if the request was succesfully read and parsed. False if an invalid SCGI header was
	 *   received by the parser or if the header information was invalid.
	 * @throws SystemException Request header could not be read.
	 */
	bool readAndParseRequestHeaders(FileDescriptor &fd, ScgiRequestParser &parser, string &requestBody) {
		TRACE_POINT();
		char buf[1024 * 16];
		ssize_t size;
		unsigned int accepted = 0;
		
		do {
			size = syscalls::read(fd, buf, sizeof(buf));
			if (size == -1) {
				throw SystemException("Cannot read request header", errno);
			} else if (size == 0) {
				break;
			} else {
				accepted = parser.feed(buf, size);
			}
		} while (parser.acceptingInput());

		if (parser.getState() != ScgiRequestParser::DONE) {
			if (parser.getState() == ScgiRequestParser::ERROR
			 && parser.getErrorReason() == ScgiRequestParser::LIMIT_REACHED) {
				P_ERROR("SCGI header too large.");
			} else {
				P_ERROR("Invalid SCGI header received: " <<
					cEscapeString(parser.getHeaderData()));
			}
			return false;
		} else if (!parser.hasHeader("DOCUMENT_ROOT")) {
			P_ERROR("DOCUMENT_ROOT header is missing.");
			return false;
		} else {
			requestBody.assign(buf + accepted, size - accepted);
			return true;
		}
	}
	
	/**
	 * Sends a request body to this client. The <tt>partialRequestBody</tt> will first be
	 * sent to the specified <tt>session</tt>, but if the specified <tt>contentLength</tt>
	 * is larger than the size of the <tt>partialRequestBody</tt>, then this method will
	 * attempt to read the remaining bytes from the specified <tt>clientFd</tt> and send it
	 * to the <tt>session</tt> as well until <tt>contentLength</tt> bytes have been sent in
	 * total.
	 *
	 * @param session The Ruby on Rails application instance.
	 * @param clientFd The client file descriptor to send the request body to.
	 * @param partialRequestBody The partial request body to send to this client.
	 * @param contentLength The content length of the request body in bytes.
	 * @throws SystemException Request body could not be read from the specified
	 *   <tt>clientFd</tt>.
	 */
	void sendRequestBody(SessionPtr &session,
	                     FileDescriptor &clientFd,
	                     const string &partialRequestBody,
	                     unsigned long contentLength) {
		TRACE_POINT();
		char buf[1024 * 16];
		ssize_t size;
		size_t bytesToRead;
		unsigned long bytesForwarded = 0;
		
		if (partialRequestBody.size() > 0) {
			UPDATE_TRACE_POINT();
			session->sendBodyBlock(partialRequestBody.c_str(),
				partialRequestBody.size());
			bytesForwarded = partialRequestBody.size();
		}
		
		bool done = bytesForwarded == contentLength;
		while (!done) {
			UPDATE_TRACE_POINT();
			
			bytesToRead = contentLength - bytesForwarded;
			if (bytesToRead > sizeof(buf)) {
				bytesToRead = sizeof(buf);
			}
			size = syscalls::read(clientFd, buf, bytesToRead);
			
			if (size == 0) {
				done = true;
			} else if (size == -1) {
				throw SystemException("Cannot read request body", errno);
			} else {
				UPDATE_TRACE_POINT();
				session->sendBodyBlock(buf, size);
				bytesForwarded += size;
				done = bytesForwarded == contentLength;
			}
		}
	}
	
	/**
	 * Forwards an HTTP response from the given (Rails) <tt>session</tt> to the
	 * given <tt>clientFd</tt>.
	 * 
	 * @param session The Ruby on Rails session to read the response from.
	 * @param clientFd The client file descriptor to write the response to.
	 * @throws SystemException Something went wrong while reading the response
	 *                         from the backend process or while writing to the
	 *                         response back to the web server.
	 * @throws ClientDisconnectedException The HTTP client closed the connection
	 *                                     before we were able to send back the
	 *                                     full response.
	 */
	void forwardResponse(SessionPtr &session, FileDescriptor &clientFd,
		const AnalyticsLogPtr &log)
	{
		TRACE_POINT();
		int stream = session->getStream();
		int eof = false;
		char buf[1024 * 24];
		size_t accepted;
		ssize_t size;
		bool chunked = false;
		Dechunker dechunker;
		
		currentClient = clientFd;
		
		/* Read data from the backend process until we
		 * have at least an entire response header, or
		 * until some error occurred.
		 */
		headerBufferer.reset();
		while (!eof && headerBufferer.acceptingInput()) {
			UPDATE_TRACE_POINT();
			size = syscalls::read(stream, buf, sizeof(buf));
			if (size == 0) {
				eof = true;
			} else if (size == -1) {
				throw SystemException("Cannot read response from backend process", errno);
			} else {
				accepted = headerBufferer.feed(buf, size);
			}
		}
		
		/* Now process the response header as well as whatever part of the
		 * response body we've already received.
		 */
		if (!headerBufferer.acceptingInput() && !headerBufferer.hasError()) {
			UPDATE_TRACE_POINT();
			assert(!eof);
			StaticString headerData = headerBufferer.getData();
			StaticString nonHeaderData(buf + accepted, size - accepted);
			StaticString status;
			char statusTmp[32];
			
			status = extractAndSanitizeHttpStatus(headerData, statusTmp);
			/* Nginx's proxy_module doesn't support HTTP 1.1 chunked
			 * transfer encoding so we need to strip that header and
			 * dechunk the data before passing to Nginx.
			 */
			chunked = detectChunkedTransferEncodingAndRemoveHeader(headerData);
			
			if (!log->isNull()) {
				UPDATE_TRACE_POINT();
				log->message("Status: " + status);
			}
			
			UPDATE_TRACE_POINT();
			
			StaticString parts[6];
			unsigned int nparts = 0;
			parts[nparts++] = "HTTP/1.1 ";
			parts[nparts++] = status;
			if (chunked) {
				P_TRACE(2, "Chunked response detected");
				// Disable Nginx response buffering.
				parts[nparts++] = "\r\nX-Accel-Buffering: no\r\n";
			} else {
				parts[nparts++] = "\r\n";
			}
			parts[nparts++] = headerData;
			if (!chunked) {
				// If the response doesn't have the chunked transfer encoding
				// then forward the beginning of the response body as-in.
				// Otherwise we have to filter it through the dechunker.
				parts[nparts++] = nonHeaderData;
			}
			
			try {
				gatheredWrite(clientFd, parts, nparts);
			} catch (const SystemException &e) {
				if (e.code() == EPIPE) {
					throw ClientDisconnectedException();
				} else {
					throw;
				}
			}
			
			if (chunked) {
				dechunker.onData = forwardResponseChunk;
				dechunker.userData = this;
				dechunker.feed(nonHeaderData.data(), nonHeaderData.size());
				if (dechunker.hasError()) {
					P_ERROR("The backend process's chunked response is not valid (" <<
						dechunker.getErrorMessage() << ")");
					return;
				}
			}
			
		} else if (!headerBufferer.acceptingInput()) {
			// Error: header too large.
			assert(!eof);
			assert(headerBufferer.hasError());
			P_ERROR("The backend process's HTTP response header is too large. "
				"For security reasons Phusion Passenger doesn't allow response "
				"headers larger than 128 KB.");
			return;
			
		} else {
			// Error: incomplete header.
			assert(eof);
			return;
		}
		
		/* Forward remaining response body. */
		UPDATE_TRACE_POINT();
		while (!eof) {
			UPDATE_TRACE_POINT();
			size = syscalls::read(stream, buf, sizeof(buf));
			if (size == 0) {
				eof = true;
			} else if (size == -1) {
				throw SystemException("Cannot read response from backend process", errno);
			} else {
				UPDATE_TRACE_POINT();
				if (chunked) {
					dechunker.feed(buf, size);
					if (dechunker.hasError()) {
						P_ERROR("The backend process's chunked response is not valid (" <<
							dechunker.getErrorMessage() << ")");
						return;
					}
				} else {
					forwardResponseChunk(buf, size, this);
				}
			}
		}
		
		if (chunked && dechunker.acceptingInput()) {
			P_WARN("The backend process's chunked response lacks a terminating chunk.");
		}
	}
	
	static void forwardResponseChunk(const char *data, size_t size, void *userData) {
		Client *self = (Client *) userData;
		try {
			writeExact(self->currentClient, data, size);
		} catch (const SystemException &e) {
			if (e.code() == EPIPE) {
				throw ClientDisconnectedException();
			} else {
				throw;
			}
		}
	}
	
	/**
	 * Handles a spawn related exception by writing an appropriate HTTP error response (500)
	 * for the given spawn exception <tt>e</ee> to given file descriptor <tt>fd</tt>'s message
	 * channel.
	 *
	 * @param fd The file descriptor identifying the message channel to write the given
	 *   spawn exception <tt>e</tt> to.
	 * @param e The spawn exception to be written to the given <tt>fd</tt>'s message
	 *   channel.
	 * @param friendly Whether to show a friendly error page.
	 */
	void handleSpawnException(FileDescriptor &fd, const SpawnException &e, bool friendly) {
		writeExact(fd, "HTTP/1.1 500 Internal Server Error\x0D\x0A");
		writeExact(fd, "Status: 500 Internal Server Error\x0D\x0A");
		writeExact(fd, "Connection: close\x0D\x0A");
		writeExact(fd, "Content-Type: text/html; charset=utf-8\x0D\x0A");
		
		if (friendly) {
			if (e.hasErrorPage()) {
				writeExact(fd, "Content-Length: " +
					toString(e.getErrorPage().size()) +
					"\x0D\x0A");
				writeExact(fd, "\x0D\x0A");
				writeExact(fd, e.getErrorPage());
			} else {
				writeExact(fd, "Content-Length: " +
					toString(strlen(e.what())) + "\x0D\x0A");
				writeExact(fd, "\x0D\x0A");
				writeExact(fd, e.what());
			}
		} else {
			const char body[] = "<h1>Internal Server Error (500)</h1>";
			writeExact(fd, "Content-Length: " +
				toString(strlen(body)) + "\x0D\x0A");
			writeExact(fd, "\x0D\x0A");
			writeExact(fd, body);
		}
	}
	
	/**
	 * Handles an SCGI request from a client whose identity is derived by the given <tt>clientFd</tt>.
	 *
	 * @param clientFd The file descriptor identifying the client to handle the request from.
	 */
	void handleRequest(FileDescriptor &clientFd) {
		TRACE_POINT();
		ScgiRequestParser parser(MAX_HEADER_SIZE);
		string partialRequestBody;
		
		if (!readAndCheckPassword(clientFd)) {
			P_ERROR("Client did not send a correct password.");
			return;
		}
		if (!readAndParseRequestHeaders(clientFd, parser, partialRequestBody)) {
			return;
		}
		
		try {
			bool useUnionStation = parser.getHeader("UNION_STATION_SUPPORT") == "true";
			StaticString appGroupName = parser.getHeader("PASSENGER_APP_GROUP_NAME");
			PoolOptions options;
			
			if (parser.getHeader("SCRIPT_NAME").empty()) {
				options.appRoot = extractDirName(parser.getHeader("DOCUMENT_ROOT"));
			} else {
				options.appRoot = extractDirName(resolveSymlink(parser.getHeader("DOCUMENT_ROOT")));
				options.baseURI = parser.getHeader("SCRIPT_NAME");
			}
			if (appGroupName.empty()) {
				options.appGroupName = options.appRoot;
			} else {
				options.appGroupName = appGroupName;
			}
			options.useGlobalQueue = parser.getHeader("PASSENGER_USE_GLOBAL_QUEUE") == "true";
			options.environment    = parser.getHeader("PASSENGER_ENVIRONMENT");
			options.spawnMethod    = parser.getHeader("PASSENGER_SPAWN_METHOD");
			options.user           = parser.getHeader("PASSENGER_USER");
			options.group          = parser.getHeader("PASSENGER_GROUP");
			options.defaultUser    = defaultUser;
			options.defaultGroup   = defaultGroup;
			options.appType        = parser.getHeader("PASSENGER_APP_TYPE");
			options.rights         = Account::parseRightsString(
				parser.getHeader("PASSENGER_APP_RIGHTS"),
				DEFAULT_BACKEND_ACCOUNT_RIGHTS);
			options.minProcesses   = atol(parser.getHeader("PASSENGER_MIN_INSTANCES"));
			options.maxRequests    = atol(parser.getHeader("PASSENGER_MAX_REQUESTS"));
			options.frameworkSpawnerTimeout = atol(parser.getHeader("PASSENGER_FRAMEWORK_SPAWNER_IDLE_TIME"));
			options.appSpawnerTimeout       = atol(parser.getHeader("PASSENGER_APP_SPAWNER_IDLE_TIME"));
			options.debugger       = parser.getHeader("PASSENGER_DEBUGGER") == "true";
			options.showVersionInHeader = parser.getHeader("PASSENGER_SHOW_VERSION_IN_HEADER") == "true";
			
			UPDATE_TRACE_POINT();
			AnalyticsLogPtr log;
			if (useUnionStation) {
				log = analyticsLogger->newTransaction(
					options.getAppGroupName(),
					"requests",
					parser.getHeader("PASSENGER_UNION_STATION_KEY"),
					parser.getHeader("UNION_STATION_FILTERS"));
				options.analytics = true;
				options.log = log;
			} else {
				log.reset(new AnalyticsLog());
			}
			
			AnalyticsScopeLog requestProcessingScope(log, "request processing");
			log->message("URI: " + parser.getHeader("REQUEST_URI"));
			
			/***********************/
			/***********************/
			
			try {
				SessionPtr session;
				
				{
					AnalyticsScopeLog scope(log, "get from pool");
					session = pool->get(options);
					scope.success();
					log->message("Application PID: " + toString(session->getPid()) +
						" (GUPID: " + session->getGupid() + ")");
				}
				
				UPDATE_TRACE_POINT();
				AnalyticsScopeLog requestProxyingScope(log, "request proxying");
				
				char headers[parser.getHeaderData().size() +
					sizeof("PASSENGER_CONNECT_PASSWORD") +
					session->getConnectPassword().size() + 1 +
					sizeof("PASSENGER_GROUP_NAME") +
					options.getAppGroupName().size() + 1 +
					sizeof("PASSENGER_TXN_ID") +
					log->getTxnId().size() + 1];
				char *end = headers;
				
				memcpy(end, parser.getHeaderData().c_str(), parser.getHeaderData().size());
				end += parser.getHeaderData().size();
				
				memcpy(end, "PASSENGER_CONNECT_PASSWORD", sizeof("PASSENGER_CONNECT_PASSWORD"));
				end += sizeof("PASSENGER_CONNECT_PASSWORD");
				
				memcpy(end, session->getConnectPassword().c_str(),
					session->getConnectPassword().size() + 1);
				end += session->getConnectPassword().size() + 1;
				
				if (!log->isNull()) {
					memcpy(end, "PASSENGER_GROUP_NAME", sizeof("PASSENGER_GROUP_NAME"));
					end += sizeof("PASSENGER_GROUP_NAME");
					
					memcpy(end, options.getAppGroupName().c_str(),
						options.getAppGroupName().size() + 1);
					end += options.getAppGroupName().size() + 1;
					
					memcpy(end, "PASSENGER_TXN_ID", sizeof("PASSENGER_TXN_ID"));
					end += sizeof("PASSENGER_TXN_ID");
					
					memcpy(end, log->getTxnId().c_str(),
						log->getTxnId().size() + 1);
					end += log->getTxnId().size() + 1;
				}
				
				{
					AnalyticsScopeLog scope(log, "send request headers");
					session->sendHeaders(headers, end - headers);
					scope.success();
				}
				{
					AnalyticsScopeLog scope(log, "send request body");
					unsigned long contentLength = atol(
						parser.getHeader("CONTENT_LENGTH").c_str());
					sendRequestBody(session,
						clientFd,
						partialRequestBody,
						contentLength);
					session->shutdownWriter();
					scope.success();
				}
				
				forwardResponse(session, clientFd, log);
				
				requestProxyingScope.success();
			} catch (const SpawnException &e) {
				handleSpawnException(clientFd, e,
					parser.getHeader("PASSENGER_FRIENDLY_ERROR_PAGES") == "true");
			} catch (const ClientDisconnectedException &) {
				P_WARN("Couldn't forward the HTTP response back to the HTTP client: "
					"It seems the user clicked on the 'Stop' button in his "
					"browser.");
			}
			
			requestProcessingScope.success();
			clientFd.close();
		} catch (const boost::thread_interrupted &) {
			throw;
		} catch (const tracable_exception &e) {
			P_ERROR("Uncaught exception in PassengerServer client thread:\n"
				<< "   exception: " << e.what() << "\n"
				<< "   backtrace:\n" << e.backtrace());
		} catch (const std::exception &e) {
			P_ERROR("Uncaught exception in PassengerServer client thread:\n"
				<< "   exception: " << e.what() << "\n"
				<< "   backtrace: not available");
		}
	}
	
	/**
	 * This client's main thread, responsible for accepting connections made by a client
	 * to the server and to handle its request.
	 *
	 * @see acceptConnection(void)
	 * @see handleRequest(FileDescriptor)
	 */
	void threadMain() {
		TRACE_POINT();
		try {
			while (true) {
				UPDATE_TRACE_POINT();
				inactivityTimer.start();
				FileDescriptor fd(acceptConnection());
				inactivityTimer.stop();
				handleRequest(fd);
			}
		} catch (const boost::thread_interrupted &) {
			P_TRACE(2, "Client thread " << this << " interrupted.");
		} catch (const tracable_exception &e) {
			P_ERROR("Uncaught exception in PassengerServer client thread:\n"
				<< "   exception: " << e.what() << "\n"
				<< "   backtrace:\n" << e.backtrace());
			abort();
		}
	}
	
public:
	/**
	 * Constructs a client handler for the server with the given arguments and runs
	 * it in its own thread.
	 *
	 * @param number The id assigned by the server to identify this client by.
	 * @param pool The application pool where this client belongs to.
	 * @param password The password that is required to connect to this client handler.
	 *   This value is determined and assigned by the server.
	 * @param serverSocket The server socket to accept this clients connection from.
	 */
	Client(unsigned int number, ApplicationPool::Ptr pool,
	       const string &password, const string &defaultUser,
	       const string &defaultGroup, int serverSocket,
	       const AnalyticsLoggerPtr &logger)
		: inactivityTimer(false)
	{
		this->number = number;
		this->pool = pool;
		this->password = password;
		this->defaultUser = defaultUser;
		this->defaultGroup = defaultGroup;
		this->serverSocket = serverSocket;
		this->analyticsLogger = logger;
		
		sbmh_init(&statusFinder.ctx, NULL, NULL, 0);
		sbmh_init(&transferEncodingFinder.ctx, NULL, NULL, 0);
		
		thr = new oxt::thread(
			boost::bind(&Client::threadMain, this),
			"Client thread " + toString(number),
			CLIENT_THREAD_STACK_SIZE
		);
	}
	
	/**
	 * Destroys this client and its thread.
	 */
	~Client() {
		TRACE_POINT();
		this_thread::disable_syscall_interruption dsi;
		this_thread::disable_interruption di;
		
		if (thr->joinable()) {
			thr->interrupt_and_join();
		}
		delete thr;
	}
	
	oxt::thread *getThread() const {
		return thr;
	}
	
	unsigned long long inactivityTime() const {
		return inactivityTimer.elapsed();
	}
	
	void resetInactivityTimer() {
		inactivityTimer.start();
	}
};

typedef shared_ptr<Client> ClientPtr;

/**
 * A representation of the Server responsible for handling Client instances.
 *
 * @see Client
 */
class Server {
private:
	static const int MESSAGE_SERVER_THREAD_STACK_SIZE = 64 * 128;
	
	FileDescriptor feedbackFd;
	bool userSwitching;
	string defaultUser;
	string defaultGroup;
	unsigned int numberOfThreads;
	FileDescriptor requestSocket;
	string requestSocketPassword;
	ServerInstanceDir serverInstanceDir;
	ServerInstanceDir::GenerationPtr generation;
	set<ClientPtr> clients;
	AnalyticsLoggerPtr analyticsLogger;
	ApplicationPool::Ptr pool;
	AccountsDatabasePtr accountsDatabase;
	MessageServerPtr messageServer;
	ResourceLocator resourceLocator;
	shared_ptr<oxt::thread> prestarterThread;
	shared_ptr<oxt::thread> messageServerThread;
	EventFd exitEvent;
	
	string getRequestSocketFilename() const {
		return generation->getPath() + "/request.socket";
	}
	
	/**
	 * Starts listening for client connections on this server's request socket.
	 *
	 * @throws SystemException Something went wrong while trying to create and bind to the Unix socket.
	 * @throws RuntimeException Something went wrong.
	 */
	void startListening() {
		this_thread::disable_syscall_interruption dsi;
		requestSocket = createUnixServer(getRequestSocketFilename().c_str());
		
		int ret;
		do {
			ret = chmod(getRequestSocketFilename().c_str(), S_ISVTX |
				S_IRUSR | S_IWUSR | S_IXUSR |
				S_IRGRP | S_IWGRP | S_IXGRP |
				S_IROTH | S_IWOTH | S_IXOTH);
		} while (ret == -1 && errno == EINTR);
	}
	
	/**
	 * Starts the client handler threads that are responsible for handling the communication
	 * between the client and this Server.
	 *
	 * @see Client
	 */
	void startClientHandlerThreads() {
		for (unsigned int i = 0; i < numberOfThreads; i++) {
			ClientPtr client(new Client(i + 1, pool, requestSocketPassword,
				defaultUser, defaultGroup, requestSocket,
				analyticsLogger));
			clients.insert(client);
		}
	}
	
	/**
	 * Lowers this process's privilege to that of <em>username</em> and <em>groupname</em>.
	 */
	void lowerPrivilege(const string &username, const string &groupname) {
		struct passwd *userEntry;
		struct group  *groupEntry;
		int            e;
		
		userEntry = getpwnam(username.c_str());
		if (userEntry == NULL) {
			throw NonExistentUserException(string("Unable to lower Passenger "
				"HelperAgent's privilege to that of user '") + username +
				"': user does not exist.");
		}
		groupEntry = getgrnam(groupname.c_str());
		if (groupEntry == NULL) {
			throw NonExistentGroupException(string("Unable to lower Passenger "
				"HelperAgent's privilege to that of user '") + username +
				"': user does not exist.");
		}
		
		if (initgroups(username.c_str(), userEntry->pw_gid) != 0) {
			e = errno;
			throw SystemException(string("Unable to lower Passenger HelperAgent's "
				"privilege to that of user '") + username +
				"': cannot set supplementary groups for this user", e);
		}
		if (setgid(groupEntry->gr_gid) != 0) {
			e = errno;
			throw SystemException(string("Unable to lower Passenger HelperAgent's "
				"privilege to that of user '") + username +
				"': cannot set group ID", e);
		}
		if (setuid(userEntry->pw_uid) != 0) {
			e = errno;
			throw SystemException(string("Unable to lower Passenger HelperAgent's "
				"privilege to that of user '") + username +
				"': cannot set user ID", e);
		}
	}
	
	void resetWorkerThreadInactivityTimers() {
		set<ClientPtr>::iterator it;
		
		for (it = clients.begin(); it != clients.end(); it++) {
			ClientPtr client = *it;
			client->resetInactivityTimer();
		}
	}
	
	unsigned long long minWorkerThreadInactivityTime() const {
		set<ClientPtr>::const_iterator it;
		unsigned long long result = 0;
		
		for (it = clients.begin(); it != clients.end(); it++) {
			ClientPtr client = *it;
			unsigned long long inactivityTime = client->inactivityTime();
			if (inactivityTime < result || it == clients.begin()) {
				result = inactivityTime;
			}
		}
		return result;
	}
	
public:
	Server(FileDescriptor feedbackFd, pid_t webServerPid, const string &tempDir,
		bool userSwitching, const string &defaultUser, const string &defaultGroup,
		const string &passengerRoot, const string &rubyCommand, unsigned int generationNumber,
		unsigned int maxPoolSize, unsigned int maxInstancesPerApp, unsigned int poolIdleTime,
		const VariantMap &options)
		: serverInstanceDir(webServerPid, tempDir, false),
		  resourceLocator(passengerRoot)
	{
		string messageSocketPassword;
		string loggingAgentPassword;
		
		TRACE_POINT();
		this->feedbackFd    = feedbackFd;
		this->userSwitching = userSwitching;
		this->defaultUser   = defaultUser;
		this->defaultGroup  = defaultGroup;
		numberOfThreads     = maxPoolSize * 4;
		
		sbmh_init(NULL, &statusFinder_occ,
			(const unsigned char *) "Status:",
			strlen("Status:"));
		sbmh_init(NULL, &transferEncodingFinder_occ,
			(const unsigned char *) "Transfer-Encoding:",
			strlen("Transfer-Encoding:"));
		
		UPDATE_TRACE_POINT();
		requestSocketPassword = Base64::decode(options.get("request_socket_password"));
		messageSocketPassword = Base64::decode(options.get("message_socket_password"));
		loggingAgentPassword  = options.get("logging_agent_password");
		generation = serverInstanceDir.getGeneration(generationNumber);
		startListening();
		accountsDatabase = AccountsDatabase::createDefault(generation,
			userSwitching, defaultUser, defaultGroup);
		accountsDatabase->add("_web_server", messageSocketPassword, false, Account::EXIT);
		messageServer = ptr(new MessageServer(generation->getPath() + "/socket", accountsDatabase));
		
		if (geteuid() == 0 && !userSwitching) {
			lowerPrivilege(defaultUser, defaultGroup);
		}
		
		UPDATE_TRACE_POINT();
		analyticsLogger = ptr(new AnalyticsLogger(options.get("logging_agent_address"),
			"logging", loggingAgentPassword));
		
		pool = ptr(new ApplicationPool::Pool(
			resourceLocator.getSpawnServerFilename(), generation,
			accountsDatabase, rubyCommand,
			analyticsLogger,
			options.getInt("log_level"),
			options.get("debug_log_file", false)
		));
		pool->setMax(maxPoolSize);
		pool->setMaxPerApp(maxInstancesPerApp);
		pool->setMaxIdleTime(poolIdleTime);
		
		messageServer->addHandler(ptr(new ApplicationPool::Server(pool)));
		messageServer->addHandler(ptr(new BacktracesServer()));
		messageServer->addHandler(ptr(new ExitHandler(exitEvent)));
		
		UPDATE_TRACE_POINT();
		writeArrayMessage(feedbackFd,
			"initialized",
			getRequestSocketFilename().c_str(),
			messageServer->getSocketFilename().c_str(),
			NULL);
		
		function<void ()> func = boost::bind(prestartWebApps,
			resourceLocator,
			options.get("prestart_urls"));
		prestarterThread = ptr(new oxt::thread(
			boost::bind(runAndPrintExceptions, func, true)
		));
	}
	
	~Server() {
		TRACE_POINT();
		this_thread::disable_syscall_interruption dsi;
		this_thread::disable_interruption di;
		oxt::thread *threads[clients.size()];
		set<ClientPtr>::iterator it;
		unsigned int i = 0;
		
		P_DEBUG("Shutting down helper agent...");
		prestarterThread->interrupt_and_join();
		if (messageServerThread != NULL) {
			messageServerThread->interrupt_and_join();
		}
		
		for (it = clients.begin(); it != clients.end(); it++, i++) {
			ClientPtr client = *it;
			threads[i] = client->getThread();
		}
		oxt::thread::interrupt_and_join_multiple(threads, clients.size());
		clients.clear();
		
		P_TRACE(2, "All threads have been shut down.");
	}
	
	void mainLoop() {
		TRACE_POINT();
		
		startClientHandlerThreads();
		function<void ()> func = boost::bind(&MessageServer::mainLoop, messageServer.get());
		messageServerThread = ptr(new oxt::thread(
			boost::bind(runAndPrintExceptions, func, true),
			"MessageServer thread", MESSAGE_SERVER_THREAD_STACK_SIZE
		));
		
		/* Wait until the watchdog closes the feedback fd (meaning it
		 * was killed) or until we receive an exit message.
		 */
		this_thread::disable_syscall_interruption dsi;
		fd_set fds;
		int largestFd;
		
		FD_ZERO(&fds);
		FD_SET(feedbackFd, &fds);
		FD_SET(exitEvent.fd(), &fds);
		largestFd = (feedbackFd > exitEvent.fd()) ? (int) feedbackFd : exitEvent.fd();
		UPDATE_TRACE_POINT();
		if (syscalls::select(largestFd + 1, &fds, NULL, NULL, NULL) == -1) {
			int e = errno;
			throw SystemException("select() failed", e);
		}
		
		if (FD_ISSET(feedbackFd, &fds)) {
			/* If the watchdog has been killed then we'll kill all descendant
			 * processes and exit. There's no point in keeping this helper
			 * server running because we can't detect when the web server exits,
			 * and because this helper agent doesn't own the server instance
			 * directory. As soon as passenger-status is run, the server
			 * instance directory will be cleaned up, making this helper agent
			 * inaccessible.
			 */
			syscalls::killpg(getpgrp(), SIGKILL);
			_exit(2); // In case killpg() fails.
		} else {
			/* We received an exit command. We want to exit 5 seconds after
			 * all worker threads have become inactive.
			 */
			resetWorkerThreadInactivityTimers();
			while (minWorkerThreadInactivityTime() < 5000) {
				syscalls::usleep(250000);
			}
		}
	}
};

/**
 * Initializes and starts the helper agent that is responsible for handling communication
 * between Nginx and the backend Rails processes.
 *
 * @see Server
 * @see Client
 */
int
main(int argc, char *argv[]) {
	TRACE_POINT();
	VariantMap options = initializeAgent(argc, argv, "PassengerHelperAgent");
	pid_t   webServerPid  = options.getPid("web_server_pid");
	string  tempDir       = options.get("temp_dir");
	bool    userSwitching = options.getBool("user_switching");
	string  defaultUser   = options.get("default_user");
	string  defaultGroup  = options.get("default_group");
	string  passengerRoot = options.get("passenger_root");
	string  rubyCommand   = options.get("ruby");
	unsigned int generationNumber   = options.getInt("generation_number");
	unsigned int maxPoolSize        = options.getInt("max_pool_size");
	unsigned int maxInstancesPerApp = options.getInt("max_instances_per_app");
	unsigned int poolIdleTime       = options.getInt("pool_idle_time");
	
	try {
		UPDATE_TRACE_POINT();
		Server server(FEEDBACK_FD, webServerPid, tempDir,
			userSwitching, defaultUser, defaultGroup,
			passengerRoot, rubyCommand, generationNumber,
			maxPoolSize, maxInstancesPerApp, poolIdleTime,
			options);
		P_DEBUG("Passenger helper agent started on PID " << getpid());
		
		UPDATE_TRACE_POINT();
		server.mainLoop();
	} catch (const tracable_exception &e) {
		P_ERROR(e.what() << "\n" << e.backtrace());
		return 1;
	} catch (const std::exception &e) {
		P_ERROR(e.what());
		return 1;
	}
	
	P_TRACE(2, "Helper agent exited.");
	return 0;
}
