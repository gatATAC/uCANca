<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- Change the encoding here if you need it, i.e. UTF-8 -->
	<xsl:output method="html" encoding="iso-8859-1" indent="yes"/>
	
	<!-- ************************************ Parameters ************************************ -->
	<!-- deploy-treeview, boolean - true if you want to deploy the tree-view at the first print -->
	<xsl:param name="param-deploy-treeview" select="'false'"/>
	
	<!-- is the client Netscape / Mozilla or Internet Explorer. Thanks to Bill, 90% of sheeps use Internet Explorer so it will the default value-->	
	<xsl:param name="param-is-netscape" select="'false'"/>

	<!-- hozizontale distance in pixels between a folder and its leaves -->
	<xsl:param name="param-shift-width" select="15"/>

	<!-- href target -->
	<!--xsl:param name="param-target" select=""/-->
	
	<!-- image source directory-->
	<xsl:param name="param-img-directory" select="'images/'"/>
	<xsl:param name="param-target" select="''" />
	
	<!-- ************************************ Variables ************************************ -->
	<xsl:variable name="var-simple-quote">'</xsl:variable>
	<xsl:variable name="var-slash-quote">\'</xsl:variable>
	<xsl:variable name="padd"><imgs></imgs></xsl:variable>
	
<!--
**
**  Model "treeview"
** 
**  This model transforms an XML treeview into an html treeview
**  
-->
	<xsl:template match="/treeview">
		<!-- -->
		<link rel="stylesheet" href="treeview.css" type="text/css"/>
		<!-- Warning, if you use-->
		<script src="treeview.js" language="javascript" type="text/javascript"></script>
		<!--table border="1" cellspacing="0" cellpadding="0">
		  	<tr><td-->
				<xsl:apply-templates select="*">
					<xsl:with-param name="depth" select="1"/>
				</xsl:apply-templates>
			<!--/td></tr>
		 </table-->
				
	</xsl:template>

<!--
**
**  Model "folder"
** 
**  This model transforms a folder element. Prints a plus (+) or minus (-)  image, the folder image and a title
**  
-->
	<xsl:template match="folder">
	<xsl:param name="depth"/>
	<xsl:param name="padd"/>
		<div style="position:relative;border:none;height:10px">
			<xsl:value-of disable-output-escaping="yes" select="$padd"/>
	  		<!-- If first level of depth, do not shift of $param-shift-width-->
	  		<xsl:if test="$depth>1">
	  		</xsl:if>
	  			<a class="folder">
				<xsl:attribute name="onclick">toggleTV(this)</xsl:attribute>
				<!-- If the treeview is unfold, the image minus (-) is displayed-->
				<xsl:if test="@expanded">
					<xsl:if test="@expanded='true'">
	  					<img src="{$param-img-directory}minus.gif"/>
	  				</xsl:if>
		  			<!-- plus (+) otherwise-->
					<xsl:if test="@expanded='false'">
						<img src="{$param-img-directory}plus.gif"/>
		  			</xsl:if>
				</xsl:if>
				<xsl:if test="not(@expanded)">
					<xsl:if test="$param-deploy-treeview = 'true'">
						<img src="{$param-img-directory}minus.gif"/>
					</xsl:if>
					
					<xsl:if test="$param-deploy-treeview = 'false' or not(@expanded)">
						<img src="{$param-img-directory}plus.gif"/>
					</xsl:if>
				</xsl:if>
	  			<img src="{$param-img-directory}{@img}"></img>
	  			<xsl:value-of select="title"/>
	  			</a>
					<div>
						<xsl:if test="@expanded">
							<xsl:if test="@expanded='true'">
		  						<xsl:attribute name="style">display:block;</xsl:attribute>
		  					</xsl:if>
			  				<!-- plus (+) otherwise-->
							<xsl:if test="@expanded='false'">
								<xsl:attribute name="style">display:none;</xsl:attribute>
			  				</xsl:if>
						</xsl:if>
						<xsl:if test="not(@expanded)">
							<xsl:if test="$param-deploy-treeview = 'true'">
								<xsl:attribute name="style">display:block;</xsl:attribute>						
							</xsl:if>
							<xsl:if test="$param-deploy-treeview = 'false'">
								<xsl:attribute name="style">display:none;</xsl:attribute>
							</xsl:if>
						</xsl:if>		
						<!--
						name:<xsl:value-of select="name(.)"/>				
						fs:sum=<xsl:value-of select="count(following-sibling::folder) + count(following-sibling::leaf)"/>
						fs:leaf=<xsl:value-of select="count(following-sibling::leaf)"/>
						fs:leaf|folder=<xsl:value-of select="count(following-sibling::leaf|folder)"/>
						-->
	  					<xsl:apply-templates>
							<xsl:with-param name="depth" select="$depth+1"/>
							<xsl:with-param name="padd"><xsl:value-of disable-output-escaping="yes" select="$padd"/>
								<xsl:text disable-output-escaping="yes">&lt;img height="16" width="16" src="</xsl:text>
								<xsl:value-of select="$param-img-directory"/>
								<xsl:choose>
									<xsl:when test="count(following-sibling::folder)+count(following-sibling::leaf)=0">
										dot.gif
									</xsl:when>
									<xsl:otherwise>
										link_all.gif
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>"/&gt;</xsl:text>
							</xsl:with-param>
						</xsl:apply-templates>
					</div>
				</div>
	</xsl:template>
	
	<xsl:template match="title"/>
	<xsl:template match="link"/>
	
<!--
**
**  Model "leaf"
** 
**  This model prints an image plus the name of the element
**  
-->
	<xsl:template match="leaf">
	<xsl:param name="depth"/>
	<xsl:param name="padd"/>
		<div style="position:relative;border:none;height:10px">
			<xsl:value-of disable-output-escaping="yes" select="$padd"/>
			<xsl:choose>
				<xsl:when test="count(following-sibling::leaf)=0">
					<xsl:choose>
						<xsl:when test="count(preceding::*)=0">
							<img height="16" width="16" src="{$param-img-directory}arrow.gif"/>
						</xsl:when>
						<xsl:otherwise>
							<img height="16" width="16"  src="{$param-img-directory}lastlink.gif"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<img src="{$param-img-directory}link.gif"/>
				</xsl:otherwise>
			</xsl:choose>
			<a class="leaf">
				<xsl:if test="link">
					<xsl:attribute name="href">
						<xsl:value-of select="link"/>
					</xsl:attribute>						
				</xsl:if>
				<xsl:choose>
					<xsl:when test="@target">
						<xsl:attribute name="target">
							<xsl:value-of select="@target"/>
						</xsl:attribute>						
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="not($param-target = '')">
							<xsl:attribute name="target"><xsl:value-of select="$param-target"/></xsl:attribute>						
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<img border="0" src="{$param-img-directory}{@img}">
				</img>
				<xsl:value-of select="title" />
			</a>
	   	</div>
	</xsl:template>
	
</xsl:stylesheet>




