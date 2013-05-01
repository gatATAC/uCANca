<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" indent="yes"/>

<!--
**
**	DERIVED BY AJD FROM THE WORK OF Jean-Michel Garnier ESQ
**
-->
	
<!-- 
**
**  Parameters 
**
-->
	<!-- allow expansion of folder hierarchy -->
	<xsl:param name="param-deploy-treeview" select="'true'"/>
	
	<!-- maximum number of folder levels to expand -->
	<xsl:param name="param-max-expansion-depth" select="1"/>	
	
	<!-- is the client Netscape / Mozilla or Internet Explorer. Thanks to Bill, 90% of sheeps use Internet Explorer so it will the default value-->	
	<xsl:param name="param-is-netscape" select="'false'"/>

	<!-- hozizontale distance in pixels between a folder and its leaves -->
	<xsl:param name="param-shift-width" select="15"/>
	
	<!-- image source directory-->
	<xsl:param name="param-img-directory" select="''"/>
	
<!-- 
**
**  Constants
**
-->
	<xsl:variable name="var-simple-quote">'</xsl:variable>
	<xsl:variable name="var-slash-quote">\'</xsl:variable>
	
<!--
**
**  main template - 
**  creates a tree view of a file system hierarchy
** 
-->
	<xsl:template name="main" match="/">
			
		<table border="0" cellspacing="0" cellpadding="0">
		  	<tr><td>
		  		<!-- Apply the template folder starting with a depth in the tree of 1-->
				<xsl:apply-templates select="/TREEVIEW/FOLDER">
					<xsl:with-param name="depth" select="1"/>
				</xsl:apply-templates>
			</td></tr>
		 </table>
				
	</xsl:template>

<!--
**
**  "folder" template - 
**  transforms a folder element into the appropriate HTML presentation code. 
**  this causes a plus (+) or minus (-) image, the folder image and the folder title to be printed
**  
-->
	<xsl:template name="folder" match="FOLDER">
		<xsl:param name="depth"/>
		
		<!-- determine if this is the root folder -->
		<xsl:variable name="rootfolder">
		<xsl:choose>
			<xsl:when test="$depth = 1">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>		
		
		<!-- determine if we need to expand this folder -->
		<xsl:variable name="expand">
		<xsl:choose>
			<xsl:when test="$depth > $param-max-expansion-depth">false</xsl:when>
			<xsl:otherwise>true</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>			
		
		<table border="0" cellspacing="0" cellpadding="0">
	  		<tr>
				
				<xsl:if test="$rootfolder = 'false'">
					<td width="{$param-shift-width}"></td>
	  			</xsl:if>
	  			
	  			<td>	  			
	  				<a class="folder">	  				
						<!-- if this folder has child contents ... -->
						<xsl:choose>
						<xsl:when test="boolean(./*)">
							<!-- set the onClick event handler -->
							<xsl:attribute name="onclick">toggle(this)</xsl:attribute>
						
							<!-- display a "plus" or "minus" image as appropriate -->	
							<xsl:choose>
							<xsl:when test="$expand = 'true'">
		  						<img src="{$param-img-directory}minus.gif"/>
							</xsl:when>
							<xsl:otherwise>
								<img src="{$param-img-directory}plus.gif"/>
							</xsl:otherwise>
							</xsl:choose>						
						</xsl:when>
						<xsl:otherwise>
							<img src="{$param-img-directory}spacer.gif"/>
						</xsl:otherwise>						
						</xsl:choose>
												
		  				<xsl:choose>
						<xsl:when test="$rootfolder = 'true'">
	  						<img src="{$param-img-directory}docroot.gif"/>
						</xsl:when>
						<xsl:otherwise>
							<img src="{$param-img-directory}folder.gif"/>
						</xsl:otherwise>
						</xsl:choose>	  				
		  				
		  				<xsl:value-of select="'&amp;nbsp;'" disable-output-escaping="yes"/>
		  				<xsl:value-of select="@name"/>	  				
	  				</a>
					
					<!-- decide if the contents of this branch should be expanded by default -->
					<div>
						<xsl:choose>
						<xsl:when test="$expand = 'true'">
	  						<xsl:attribute name="style">display:block;</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="style">display:none;</xsl:attribute>
						</xsl:otherwise>						
						</xsl:choose>					
						
						<!-- use recursion to create all the descendants of the present folder -->
	  					<xsl:apply-templates select="FOLDER">
							<xsl:with-param name="depth" select="$depth+1"/>
						</xsl:apply-templates>
						
						<!-- print all the leaves of this folder-->
	  					<xsl:apply-templates select="FILE"/>
					</div>
					
	  			</td>
	  		</tr>
	  	</table>
	  	
	</xsl:template>
	
<!--
**
**  "file" template -
**  transforms a file element into the appropriate HTML presentation code.
**  makes a hyperlink to the file in question around an image 
**  (selected according to the file type) plus the name of the file,
**
-->
	<xsl:template name="file" match="FILE">

		<!-- use replace-string template to escape the file name -->
        <xsl:variable name="escapedName">
        <xsl:call-template name="replace-string">
            <xsl:with-param name="text" select="@name"/>
            <xsl:with-param name="from" select="$var-simple-quote"/>
            <xsl:with-param name="to" select="$var-slash-quote"/>
        </xsl:call-template>
        </xsl:variable>
        
        <!-- use replace-string template to escape the file path -->
        <xsl:variable name="escapedPath">
        <xsl:call-template name="replace-string">
            <xsl:with-param name="text" select="@path"/>
            <xsl:with-param name="from" select="$var-simple-quote"/>
            <xsl:with-param name="to" select="$var-slash-quote"/>
        </xsl:call-template>
        </xsl:variable>
        
        <!-- determine which image to use for the line back to the parent folder -->
        <xsl:variable name="lineImage">
		<xsl:choose>
			<xsl:when test="position()=last()">lastlink.gif</xsl:when>
			<xsl:otherwise>link.gif</xsl:otherwise>
		</xsl:choose>
        </xsl:variable>
        
        <!-- determine which image to use for file itself, according to its type -->
        <xsl:variable name="fileImage">
		<xsl:choose>
			<xsl:when test="@type = 'Adobe Acrobat Document'">pdf.gif</xsl:when>
			<xsl:when test="@type = 'Microsoft Word Document'">worddoc.gif</xsl:when>
			<xsl:when test="@type = 'HTML Document'">ie_link.gif</xsl:when>
			<xsl:otherwise>leaf.gif</xsl:otherwise>
		</xsl:choose>
        </xsl:variable>                	
		
		<table border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td width="{$param-shift-width}"></td> 
				<td>
                    <a 
                    	class="leaf"
                    	onClick="selectLeaf('{normalize-space($escapedName)}','{normalize-space($escapedPath)}')"
                    >					
	                    <img src="{concat($param-img-directory,$lineImage)}"/>						
						<img src="{concat($param-img-directory,$fileImage)}"/>
					</a>
					<a class="filename" href="{concat(@path,@name)}" target="_blank">
						<xsl:value-of select="'&amp;nbsp;'" disable-output-escaping="yes"/>
						<xsl:value-of select="@name"/>
					</a>
				</td>
			</tr>
   		</table>
	</xsl:template>
	
<!--
**
**  "replace-string" template -
**  recursive template that recreates a substring replacement procedure
**  
-->
	<xsl:template name="replace-string">
		<xsl:param name="text"/>
		<xsl:param name="from"/>
		<xsl:param name="to"/>
		<xsl:choose>
			<xsl:when test="contains($text, $from)">
				<xsl:variable name="before" select="substring-before($text, $from)"/>
				<xsl:variable name="after" select="substring-after($text, $from)"/>
				<xsl:variable name="prefix" select="concat($before, $to)"/>
				<xsl:value-of select="$before"/>
				<xsl:value-of select="$to"/>
				<xsl:call-template name="replace-string">
					<xsl:with-param name="text" select="$after"/>
					<xsl:with-param name="from" select="$from"/>
					<xsl:with-param name="to" select="$to"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
</xsl:stylesheet>




