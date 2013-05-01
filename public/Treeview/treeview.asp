<HTML>

<HEAD>
	<TITLE>BMC J2EE Documentation</TITLE>
	<LINK rel="stylesheet" href="/j2ee/css/j2ee.css" type="text/css">
	<SCRIPT src="treeview.js" language="javascript" type="text/javascript"></SCRIPT>	
</HEAD>

<BODY 
 topMargin="30" 
 leftMargin="40" 
 rightMargin="40" 
 bottomMargin="30"
>

	<TABLE 
	 border="0" 
	 cellspacing="2" 
	 cellpadding="2" 
	 width="60%" 
	 align="center" 
	 bgcolor="#dcdcdc" 
	>  
	  <TR>
	    <TD bgcolor="#000000" width="130" valign="middle">
			<IMG src="/j2ee/images/bmc.gif" border="0">
		</TD>
	    <TD bgcolor="#696969" valign="middle" class="DocTitle">
			Documentation Index    
	    </TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#696969" width="130" valign="top" class="Heading">
			Home
	    </TD>
	    <TD bgcolor="#FFFFFF" valign="top">
			<B>Docs</B>        
	    </TD>
	  </TR>  
	  <TR>
	    <TD bgcolor="#696969" width="130" valign="top" class="Heading">
			Author
	    </TD>
	    <TD bgcolor="#FFFFFF" valign="top">
			Alastair Dant / Jean-Michel Garnier     
	    </TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#696969" width="130" valign="top" class="Heading">
			Version
	    </TD>
	    <TD bgcolor="#FFFFFF" valign="top">
			1.0   
	    </TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#696969" width="130" valign="top" class="Heading">
			Last Revised
	    </TD>
	    <TD bgcolor="#FFFFFF" valign="top">
			<%Response.Write(FormatDateTime("" & Date,1))%>
	    </TD>
	  </TR>
	</TABLE>
	<BR/>
	<TABLE 
	 border="0" 
	 cellspacing="2" 
	 cellpadding="2" 
	 width="60%" 
	 align="center" 
	 bgcolor="#dcdcdc" 
	>  
	  <TR>
	    <TD bgcolor="#C0C0C0" valign="middle" class="SectionName">
			Documentation Repository
	    </TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#FFFFFF" valign="middle">
			Use the tree view below to browse the current contents of the repository.
			The "Content suggestions" document describes our current intentions for additional items.
			Having read it through, please <A HREF="mailto:alastair@biomedcentral.com?subject=J2EE documentation">contact me</A>
			if you think anything should be a priority requirement, or feel that something important is missing,
		</TD>
	  </TR>
	  <TR>
		<TD bgcolor="#FFFFFF" valign="middle">	 		
			<BR/><%Server.Execute("makeview.asp")%><BR/>        
	    </TD>
	  </TR>  
	</TABLE>
	<BR/>
	<TABLE 
	 border="0" 
	 cellspacing="2" 
	 cellpadding="2" 
	 width="60%" 
	 align="center" 
	 bgcolor="#dcdcdc" 
	>  
	  <TR>
	    <TD bgcolor="#C0C0C0" valign="middle" class="SectionName">
			API Documentation
	    </TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#FFFFFF" valign="middle">
			Another aspect of our new systems is the automatic generation of API documentation for all of our source code.
			The links below will take you to the top-level pages for browsing this stuff. 
		</TD>
	  </TR>
	  <TR>
	    <TD bgcolor="#FFFFFF" valign="middle">
			<a href="file:////cistalia/bmc/Bmc/Java/framework/doc/index.html">
			JavaDoc documentation for the current J2EE codebase
			</a>.		
		</TD>
	  </TR>
	  <TR>
		<TD bgcolor="#FFFFFF" valign="middle">	 		
			<a href="/documentation/submission/javadoc/index.html">
			JavaDoc documentation for all legacy Java classes
			</a>.    
	    </TD>
	  </TR>  
	  <TR>
		<TD bgcolor="#FFFFFF" valign="middle">
			<a href="/documentation/Oracle/PLSQL/doc/index.html"> 		
			PL/Doc documentation for our PL/SQL code
			</a>.	    
	    </TD>
	  </TR>
	</TABLE>

</BODY>
</HTML>
