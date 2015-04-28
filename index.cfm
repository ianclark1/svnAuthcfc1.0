<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>svnAuth.cfc Tests</title>

<style type="text/css">
	body{
font-family: Colibri, Verdana, Arial, Helvetica, sans-serif;
font-size: 60%;
}

td{
	font-size: 90%;
}
</style>

</head>
<body>

<h1>svnAuth.cfc Test</h1>

<cfset authzFile = ExpandPath('.') & "\authz" />
<cfset svnAuthObj = CreateObject("component", "svnAuth").init(authzFile) />

<h2>Testing Groups</h2>
<p>getGroups()</p>
<cfdump var="#svnAuthObj.getGroups()#" label="getGroups()" /><br />
<p>getGroupMembers('ssh_admins') - Group <strong>does</strong> exist.</p>
<cfdump var="#svnAuthObj.getGroupMembers('ssh_admins')#" label="getGroupMembers('ssh_admins')" /><br />
<p>getGroupMembers('ssh_admins2') - Group <strong>does not</strong> exist.</p>
<cfdump var="#svnAuthObj.getGroupMembers('ssh_admins2')#" label="getGroupMembers('ssh_admins2')" /><br />
<p>getGroupMembers('ssh_users') - Group <strong>does</strong> exist, but is empty.</p>
<cfdump var="#svnAuthObj.getGroupMembers('ssh_users')#" label="getGroupMembers('ssh_users')" /><br />



<h2>Testing Projects</h2>
<p>getProjects()</p>
<cfdump var="#svnAuthObj.getProjects()#" label="svnAuthObj.getProjects()" /><br />
<p>getProjectACL('/') - Project <strong>does</strong> exist.</p>
<cfdump var="#svnAuthObj.getProjectACL('/')#" label="svnAuthObj.getProjectACL('/')" /><br />
<p>getProjectACL('/squidhead') - Project <strong>does not</strong> exist.</p>
<cfdump var="#svnAuthObj.getProjectACL('/squidhead')#" label="getProjectACL('/squidhead')" /><br />

<h2>Testing Group Creation</h2>
<p>CreateGroup('ssh_admins2')</p>
<cfdump var="#svnAuthObj.CreateGroup('ssh_admins2')#" label="svnAuthObj.CreateGroup('ssh_admins2')" /><br />
<p>getGroupMembers('ssh_admins2') - should be empty.</p>
<cfdump var="#svnAuthObj.getGroupMembers('ssh_admins2')#" label="getGroupMembers('ssh_admins2')" /><br />
<p>CreateGroup('ssh_admins2') - Should fail because it already exists.</p>
<cfdump var="#svnAuthObj.CreateGroup('ssh_admins2')#" label="svnAuthObj.CreateGroup('ssh_admins2')" /><br />
<p>addMemberToGroup('ssh_admins2', 'tpryan') - Should work.</p>
<cfdump var="#svnAuthObj.addMemberToGroup('ssh_admins2', 'tpryan')#" label="addMemberToGroup('ssh_admins2', 'tpryan')" /><br />
<p>addMemberToGroup('ssh_admins2ewqe', 'tpryan') - Should fail, group does not exist.</p>
<cfdump var="#svnAuthObj.addMemberToGroup('ssh_admins2ewqe', 'tpryan')#" label="addMemberToGroup('ssh_admins2ewqe', 'tpryan')" /><br />

<h2>Testing Project Creation</h2>
<p>CreateProject('/squidhead')</p>
<cfdump var="#svnAuthObj.CreateProject('/squidhead')#" label="svnAuthObj.CreateProject('/squidhead')" /><br />
<p>getProjectACL('/squidhead') - <strong>Should</strong> work now.</p>
<cfdump var="#svnAuthObj.getProjectACL('/squidhead')#" label="getProjectACL('/squidhead')" /><br />
<p>CreateProject('/squidhead') - <strong>Should not</strong> work now.</p>
<cfdump var="#svnAuthObj.CreateProject('/squidhead')#" label="svnAuthObj.CreateProject('/squidhead')" /><br />
<p>addACLtoProject('/squidhead', 'tpryan', 'rw') - <strong>Should</strong> work .</p>
<cfdump var="#svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'rw')#" label="svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'rw')" /><br />
<p>addACLtoProject('/squidhead2', 'tpryan', 'rw') - <strong>Should not</strong> work - project does not exist.</p>
<cfdump var="#svnAuthObj.addACLtoProject('/squidhead2', 'tpryan', 'rw')#" label="svnAuthObj.addACLtoProject('/squidhead2', 'tpryan', 'rw')" /><br />
<p>addACLtoProject('/squidhead', 'tpryan', 'd') - <strong>Should </strong> work - project does exist.</p>
<cfdump var="#svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'd')#" label="svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'd')" /><br />
<p>addACLtoProject('/squidhead', 'tpryan', 'b') - <strong>Should</strong> fail - invalid permission.</p>
<cfdump var="#svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'b')#" label="svnAuthObj.addACLtoProject('/squidhead', 'tpryan', 'b')" /><br />







<cfset svnAuthObj.SaveAs("#ExpandPath('.')#\authzCommentLess") />

</body>
</html>

