<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>
<%@ taglib uri="/WEB-INF/c.tld" prefix="c" %>
<%@ taglib uri="/WEB-INF/x.tld" prefix="x" %>
<%@ taglib uri="/WEB-INF/fmt.tld" prefix="fmt" %>
<html:html locale="true">
<link rel="stylesheet" href="stylecontent.css" TYPE="text/css" />
<script language="javascript" src="content.js">
</script>
<head>
<title><bean:message key="index.title"/></title>
<html:base/>
</head>
<body class="contentbody">
<div align="center"><img src="images/logo.jpg"></div>
<br><br>
<c:set var="xmlDocument" >
<?xml version="1.0" encoding="UTF-8"?>
<treeview title="administration">
	<leaf img="users.gif">
		<title><bean:message key="content.adminusers"/></title>
		<link><html:rewrite forward="listuser"/></link> 
	</leaf>
	<folder img="folder.gif" expanded="true">
		<title><bean:message key="content.topology"/></title>
		<leaf img="leaf.gif">
			<title><bean:message key="content.machines"/></title>
			<link><html:rewrite forward="listmachine"/></link>
		</leaf>
		<folder img="folder.gif" expanded="true">
			<title><bean:message key="content.servers"/></title>
			<leaf img="leaf.gif">
				<title><bean:message key="content.iisserver"/></title>
				<link><html:rewrite page="/listserver.do?type=1"/></link>
			</leaf>
			<leaf img="leaf.gif">
				<title><bean:message key="content.apacheserver"/></title>
				<link><html:rewrite page="/listserver.do?type=2"/></link>
			</leaf>
			<leaf img="leaf.gif">
				<title><bean:message key="content.syncappserver"/></title>
				<link><html:rewrite page="/listserver.do?type=3"/></link>
			</leaf>
			<leaf img="leaf.gif">
				<title><bean:message key="content.asyncappserver"/></title>
				<link><html:rewrite page="/listserver.do?type=4"/></link>
			</leaf>
			<leaf img="leaf.gif">
				<title><bean:message key="content.iserver"/></title>
				<link><html:rewrite page="/listserver.do?type=5"/></link>
			</leaf>
			<leaf img="leaf.gif">
				<title><bean:message key="content.dbservers"/></title>
				<link><html:rewrite forward="listdbserver"/></link>
			</leaf>
		</folder>
		<leaf  img="leaf.gif">
			<title><bean:message key="content.dbinstances"/></title>
			<link><html:rewrite forward="listdbinstance"/></link>
		</leaf>
		<leaf img="leaf.gif">
			<title><bean:message key="content.applications"/></title>
			<link><html:rewrite forward="listapplication"/></link>
		</leaf>
	</folder>
	<folder img="folder.gif">
		<title><bean:message key="content.operation"/></title>
		<logic:iterate name="applications" id="app">
			<folder img="folder.gif" expanded="false">
				<title><bean:write name="app" property="name"/></title>
				<leaf img="leaf.gif">
					<title><bean:message key="content.runtimeconf"/></title>
					<link><html:rewrite forward="showruntimeconf" paramName="app" paramId="id"  paramProperty="id"/></link>
				</leaf>
				<leaf img="leaf.gif">
					<title><bean:message key="content.logs"/></title>
					<link><html:rewrite forward="showlogs" paramName="app" paramId="id"  paramProperty="id"/></link>
				</leaf>
				<leaf img="leaf.gif">
					<title><bean:message key="content.versiondeployment"/></title>
					<link><html:rewrite forward="deploy" paramName="app" paramId="id"  paramProperty="id"/></link>
				</leaf>
				<leaf img="leaf.gif">
					<title><bean:message key="content.dbmanagement"/></title>
					<link><html:rewrite href="main.htm"/></link>
				</leaf>
				<leaf img="leaf.gif">
					<title><bean:message key="content.srvmanagement"/></title>
					<link><html:rewrite forward="manageserver" paramName="app" paramId="id"  paramProperty="id"/></link>
				</leaf>
			</folder>
		</logic:iterate>
	</folder>
</treeview>
</c:set>
<c:import var="xsltDocument" url="/WEB-INF/treeview.xslt" />
<x:transform xml="${xmlDocument}" xslt="${xsltDocument}" >
<x:param name="param-img-directory" value="images/" />
<x:param name="param-target" value="main" />
</x:transform>
</body>
</html:html>