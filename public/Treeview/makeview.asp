<%@ LANGUAGE = JScript %>
<%
	// ===========================================================
	// GLOBAL CONSTANTS
	// ===========================================================

	var MAX_TREE_DEPTH      = 20;
	var MAX_DISP_DEPTH      = 1;
	var EMPTY_DOC			= "<TREEVIEW/>";
	var XSLT_PATH			= Server.MapPath("treeview.xsl");
	var IMG_DIR				= "/j2ee/images/treeview/";

	// ===========================================================
	// GLOBAL VARIABLES
	// ===========================================================

	var baseURL;	// URL for which tree view is required
	var treeFolder; // FS directory corresponding to this URL
	var XMLdoc;     // XML doc representing the folder hierarchy
	var renderer;	// renderer object

	// ===========================================================
	// MAIN CODE BLOCK
	// ===========================================================

	try
	{
	    // determine name of the URL needing to be mapped
	    baseURL = "" + Request.QueryString("base");
	    
	    // determine the corresponding logical directory path	    
	    treeFolder = Server.MapPath(baseURL);

	    // set up an XML document to contain details
	    XMLdoc = Server.CreateObject("MSXML.DOMDocument");
	    XMLdoc.loadXML(EMPTY_DOC);

	    // get the file system tree details of the current directory
	    getFSTree(treeFolder,XMLdoc,baseURL);

		// create HTML output using the renderer to transform the XML doc
		renderer = Server.CreateObject("Sitelib.Renderer");
		with (renderer)
		{
			LoadXMLFromString(XMLdoc.xml);
			LoadXSLFromFile(XSLT_PATH);
			SetXSLParameter("param-img-directory",IMG_DIR);
			SetXSLParameter("param-max-expansion-depth",MAX_DISP_DEPTH);			
			Response.Write(ProcessTransformation());
		} 
	}
	catch(e)
	{
	    throw(e);
	}
	finally
	{
	    XMLdoc = null;
	    XSLdoc = null;	
	}

	// ===========================================================
	// HELPER ROUTINES
	// ===========================================================

	function getFSTree(rootFolderName,XMLdoc,rootURL)
	{
	    var FSO;
	    var rootFolder;
	    var rootNode;

	    // set up the file system object
	    FSO = new ActiveXObject("Scripting.FileSystemObject");

	    // get the root folder of our FS tree
	    rootFolder = FSO.GetFolder(rootFolderName);

	    // add a root element to the XML doc
	    rootNode = XMLdoc.documentElement;

	    // set tree title
	    rootNode.setAttribute("title","File tree details for " + rootURL);

	    // get the tree details
	    getFolderDetails(rootFolder,0,rootNode,rootURL);
	}

	function getFolderDetails(folder, depth, parentNode, folderPath)
	{
		var folderNode;
	    var childFolders;
	    var childFolder;
	    var childPath;

	    // create a node to represent the current folder
	    folderNode = parentNode.appendChild(XMLdoc.createElement("FOLDER"));

		// set attribute data for the current folder node
	    folderNode.setAttribute("name", folder.Name);
	    folderNode.setAttribute("path", folderPath);
	    folderNode.setAttribute("type", folder.Type);

	    // get file details for the current folder
	    getFileDetails(folder, folderNode, folderPath);

		// if we haven't exceeded the maximum recursion depth
		if (!(++depth > MAX_TREE_DEPTH))
		{
	        // enumerate through all the children,
	        // recursively applying the current function
	        childFolders = new Enumerator(folder.SubFolders);

	        for (;!childFolders.atEnd();childFolders.moveNext())
	        {
	            childFolder = childFolders.item();
	            childPath = folderPath + childFolder.Name + "/" ;
	            getFolderDetails(childFolder, depth, folderNode, childPath);
	        }
		}
	}

	function getFileDetails(folder,folderNode,folderPath)
	{
	    var childFiles;
	    var childFolder;
	    var fileNode

	    // enumerate through all the files in the current folder
	    childFiles = new Enumerator(folder.Files);

	    for (;!childFiles.atEnd();childFiles.moveNext())
	    {
	        childFile = childFiles.item();
	        
	        // if the current file is not a source safe file ...
	        if (!(childFile.Type == "SCC File"))
			{        
				// add a new node to the parent folder node
				fileNode = folderNode.appendChild(XMLdoc.createElement("FILE"));

				// set appropriate attributes
				fileNode.setAttribute("name",childFile.Name);
				fileNode.setAttribute("path",folderPath);
				fileNode.setAttribute("type",childFile.Type);
			}
	    }
	}
	
	function parseErrorInfo(parseError, cause)
	{
		// return error info from DOM parser
		var errorDetails = "[" + cause + "]\n";        
		with(parseError) 
		{
			errorDetails += 
			"Code: " + errorCode + "\n" +
			"Reason: " + reason + "\n" +
			"Source: " + srcText + "\n" +
			"Location: line # " + line + " / char # " + linepos;	
		}        
		return(errorDetails);
	}
%>