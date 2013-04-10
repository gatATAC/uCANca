/*
 * OXT - OS eXtensions for boosT
 * Provides important functionality necessary for writing robust server software.
 *
 * Copyright (c) 2010 Phusion
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#include "system_calls.hpp"
#include <boost/thread.hpp>
#include <cerrno>

using namespace boost;
using namespace oxt;


/*************************************
 * oxt
 *************************************/

static void
interruption_signal_handler(int sig) {
	// Do nothing.
}

void
oxt::setup_syscall_interruption_support() {
	struct sigaction action;
	sigset_t signal_set;
	int ret;
	
	/* Very important! The signal mask is inherited across fork()
	 * and exec() and we don't know what the parent process did to
	 * us. At least on OS X, having a signal mask blocking important
	 * signals can lead to stuff like waitpid() malfunction.
	 */
	sigemptyset(&signal_set);
	do {
		ret = sigprocmask(SIG_SETMASK, &signal_set, NULL);
	} while (ret == -1 && errno == EINTR);
	
	action.sa_handler = interruption_signal_handler;
	action.sa_flags   = 0;
	sigemptyset(&action.sa_mask);
	do {
		ret = sigaction(INTERRUPTION_SIGNAL, &action, NULL);
	} while (ret == -1 && errno == EINTR);
	do {
		ret = siginterrupt(INTERRUPTION_SIGNAL, 1);
	} while (ret == -1 && errno == EINTR);
}


/*************************************
 * Passenger::syscalls
 *************************************/

#define CHECK_INTERRUPTION(error_expression, code) \
	do { \
		int _my_errno; \
		do { \
			code; \
			_my_errno = errno; \
		} while ((error_expression) && _my_errno == EINTR \
			&& !this_thread::syscalls_interruptable()); \
		if ((error_expression) && _my_errno == EINTR && this_thread::syscalls_interruptable()) { \
			throw thread_interrupted(); \
		} \
		errno = _my_errno; \
	} while (false)

int
syscalls::open(const char *path, int oflag) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::open(path, oflag)
	);
	return ret;
}

int
syscalls::open(const char *path, int oflag, mode_t mode) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::open(path, oflag, mode)
	);
	return ret;
}

ssize_t
syscalls::read(int fd, void *buf, size_t count) {
	ssize_t ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::read(fd, buf, count)
	);
	return ret;
}

ssize_t
syscalls::write(int fd, const void *buf, size_t count) {
	ssize_t ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::write(fd, buf, count)
	);
	return ret;
}

ssize_t
syscalls::writev(int fd, const struct iovec *iov, int iovcnt) {
	ssize_t ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::writev(fd, iov, iovcnt)
	);
	return ret;
}

int
syscalls::close(int fd) {
	/* Apparently POSIX says that if close() returns EINTR the
	 * file descriptor will be left in an undefined state, so
	 * when coding for POSIX we can't just loop on EINTR or we
	 * could run into race conditions with other threads.
	 * http://www.daemonology.net/blog/2011-12-17-POSIX-close-is-broken.html
	 *
	 * On Linux, FreeBSD and OpenBSD, close() releases the file
	 * descriptor when it returns EINTR. HP-UX does not.
	 * http://news.ycombinator.com/item?id=3363884
	 *
	 * MacOS X is insane because although the system call does
	 * release the file descriptor, the close() function as
	 * implemented by libSystem may call pthread_testcancel() first
	 * which can also return EINTR. Whether this happens depends
	 * on whether unix2003 is enabled.
	 * http://www.reddit.com/r/programming/comments/ng6vt/posix_close2_is_broken/c38xrgu
	 */
	#if defined(_hpux)
		int ret;
		CHECK_INTERRUPTION(
			ret == -1,
			ret = ::close(fd)
		);
		return ret;
	#else
		/* TODO: If it's not known whether the OS releases the file
		 * descriptor on EINTR-on-close(), we should print some kind of
		 * warning here. This would actually explain why some people get
		 * mysterious EBADF errors. I think the best thing we can do is
		 * to manually whitelist operating systems as we find out their
		 * behaviors.
		 */
		int ret = ::close(fd);
		if (ret == -1 && errno == EINTR && this_thread::syscalls_interruptable()) {
			throw thread_interrupted();
		} else {
			return ret;
		}
	#endif
}

int
syscalls::pipe(int filedes[2]) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::pipe(filedes)
	);
	return ret;
}

int
syscalls::dup2(int filedes, int filedes2) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::dup2(filedes, filedes2)
	);
	return ret;
}

int
syscalls::accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::accept(sockfd, addr, addrlen)
	);
	return ret;
}

int
syscalls::bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::bind(sockfd, addr, addrlen)
	);
	return ret;
}

int
syscalls::connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen) {
	int ret;
	// FIXME: I don't think this is entirely correct.
	// http://www.madore.org/~david/computers/connect-intr.html
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::connect(sockfd, serv_addr, addrlen);
	);
	return ret;
}

int
syscalls::listen(int sockfd, int backlog) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::listen(sockfd, backlog)
	);
	return ret;
}

int
syscalls::socket(int domain, int type, int protocol) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::socket(domain, type, protocol)
	);
	return ret;
}

int
syscalls::socketpair(int d, int type, int protocol, int sv[2]) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::socketpair(d, type, protocol, sv)
	);
	return ret;
}

ssize_t
syscalls::recvmsg(int s, struct msghdr *msg, int flags) {
	ssize_t ret;
	#ifdef _AIX53
		CHECK_INTERRUPTION(
			ret == -1,
			ret = ::nrecvmsg(s, msg, flags)
		);
	#else
		CHECK_INTERRUPTION(
			ret == -1,
			ret = ::recvmsg(s, msg, flags)
		);
	#endif
	return ret;
}

ssize_t
syscalls::sendmsg(int s, const struct msghdr *msg, int flags) {
	ssize_t ret;
	#ifdef _AIX53
		CHECK_INTERRUPTION(
			ret == -1,
			ret = ::nsendmsg(s, msg, flags)
		);
	#else
		CHECK_INTERRUPTION(
			ret == -1,
			ret = ::sendmsg(s, msg, flags)
		);
	#endif
	return ret;
}

int
syscalls::setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::setsockopt(s, level, optname, optval, optlen)
	);
	return ret;
}

int
syscalls::shutdown(int s, int how) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::shutdown(s, how)
	);
	return ret;
}

int
syscalls::select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *errorfds, struct timeval *timeout) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::select(nfds, readfds, writefds, errorfds, timeout)
	);
	return ret;
}

int
syscalls::poll(struct pollfd fds[], nfds_t nfds, int timeout) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::poll(fds, nfds, timeout)
	);
	return ret;
}

FILE *
syscalls::fopen(const char *path, const char *mode) {
	FILE *ret;
	CHECK_INTERRUPTION(
		ret == NULL,
		ret = ::fopen(path, mode)
	);
	return ret;
}

size_t
syscalls::fread(void *ptr, size_t size, size_t nitems, FILE *stream) {
	int ret;
	CHECK_INTERRUPTION(
		ret == 0 && ferror(stream),
		ret = ::fread(ptr, size, nitems, stream)
	);
	return ret;
}

int
syscalls::fclose(FILE *fp) {
	int ret;
	CHECK_INTERRUPTION(
		ret == EOF,
		ret = ::fclose(fp)
	);
	return ret;
}

int
syscalls::unlink(const char *pathname) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::unlink(pathname)
	);
	return ret;
}

int
syscalls::stat(const char *path, struct stat *buf) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::stat(path, buf)
	);
	return ret;
}

time_t
syscalls::time(time_t *t) {
	time_t ret;
	CHECK_INTERRUPTION(
		ret == (time_t) -1,
		ret = ::time(t)
	);
	return ret;
}

unsigned int
syscalls::sleep(unsigned int seconds) {
	// We use syscalls::nanosleep() here not only to reuse interruption
	// handling code, but also to avoid potentional infinite loops
	// in combination with oxt::thread::interrupt_and_join().
	// Upon interruption sleep() returns the number of seconds unslept
	// but interrupt_and_join() keeps interrupting the thread every 10
	// msec. Depending on the implementation of sleep(), it might return
	// the same value as its original argument. A naive implementation
	// of syscalls::sleep() that sleeps again with the return value
	// could easily cause an infinite loop. nanosleep() has a large
	// enough resolution so it won't trigger the problem.
	struct timespec spec, rem;
	int ret;
	
	spec.tv_sec = seconds;
	spec.tv_nsec = 0;
	ret = syscalls::nanosleep(&spec, &rem);
	if (ret == 0) {
		return 0;
	} else if (errno == EINTR) {
		return rem.tv_sec;
	} else {
		// No sure what to do here. There's an error
		// but we can't return -1. Let's just hope
		// this never happens.
		return 0;
	}
}

int
syscalls::usleep(useconds_t usec) {
	// We use syscalls::nanosleep() here to reuse the code that sleeps
	// for the remaining amount of time, if a signal was received but
	// system call interruption is disabled.
	struct timespec spec;
	spec.tv_sec = usec / 1000000;
	spec.tv_nsec = usec % 1000000 * 1000;
	return syscalls::nanosleep(&spec, NULL);
}

int
syscalls::nanosleep(const struct timespec *req, struct timespec *rem) {
	struct timespec req2 = *req;
	struct timespec rem2;
	int ret, e;
	do {
		ret = ::nanosleep(&req2, &rem2);
		e = errno;
		// nanosleep() on some systems is sometimes buggy. rem2
		// could end up containing a tv_sec with a value near 2^32-1,
		// probably because of integer wrapping bugs in the kernel.
		// So we check for those.
		if (rem2.tv_sec < req->tv_sec) {
			req2 = rem2;
		} else {
			req2.tv_sec = 0;
			req2.tv_nsec = 0;
		}
	} while (ret == -1 && e == EINTR && !this_thread::syscalls_interruptable());
	if (ret == -1 && e == EINTR && this_thread::syscalls_interruptable()) {
		throw thread_interrupted();
	}
	errno = e;
	if (ret == 0 && rem) {
		*rem = rem2;
	}
	return ret;
}

pid_t
syscalls::fork() {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::fork()
	);
	return ret;
}

int
syscalls::kill(pid_t pid, int sig) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::kill(pid, sig)
	);
	return ret;
}

int
syscalls::killpg(pid_t pgrp, int sig) {
	int ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::killpg(pgrp, sig)
	);
	return ret;
}

pid_t
syscalls::waitpid(pid_t pid, int *status, int options) {
	pid_t ret;
	CHECK_INTERRUPTION(
		ret == -1,
		ret = ::waitpid(pid, status, options)
	);
	return ret;
}


/*************************************
 * boost::this_thread
 *************************************/

thread_specific_ptr<bool> this_thread::_syscalls_interruptable;


bool
this_thread::syscalls_interruptable() {
	return _syscalls_interruptable.get() == NULL || *_syscalls_interruptable;
}

