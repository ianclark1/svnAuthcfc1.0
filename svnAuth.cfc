<!---
Copyright 2007 Terrence Ryan
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->


<cfcomponent hint="Provides a programmatic interface to an SVN authz file from ColdFusion." output="false">

	<cffunction access="public" name="init" output="false" returntype="svnAuth" description="Initializes the auth File interface." >
		<cfargument name="AuthzFileLocation" type="string" required="no" default="" hint="The Location of the Auth File to parse." />

		<cfset variables.AuthzFileLocation = arguments.AuthzFileLocation >

		<!--- Grab the Authz File if it exists. --->		
		<cfif len(arguments.AuthzFileLocation) gt 0 and FileExists(variables.AuthzFileLocation)>
			<cffile action="read" file="#variables.AuthzFileLocation#" variable="variables.rawAuthzFile" />
			<cfset variables.rawAuthzFile = stripComments(rawAuthzFile) />
			<cfset variables.groups = extractGroups(rawAuthzFile) />
			<cfset variables.projects = extractProjects(rawAuthzFile) />
		<cfelse>
			<cfset variables.rawAuthzFile = "" />
			<cfset variables.groups = StructNew() />
			<cfset variables.projects = StructNew() />
		</cfif>

		
	
		<cfreturn This />
	</cffunction>
		
	<cffunction access="public" name="addMemberToGroup" output="false" returntype="struct" description="Adds a member to a group. Returns success or failure within a structure." >
		<cfargument name="groupName" type="string" required="yes" hint="The group name to manipulate." />
		<cfargument name="userName" type="string" required="yes" hint="The user name to add." />
		
		<cfset var results =StructNew() />
		<cfset result.success = FALSE>
		<cfset result.message = "Unknown Issue" />
		
		<cfif structKeyExists(variables.groups, arguments.GroupName)>
			<cfset ArrayAppend(variables.groups[arguments.GroupName], arguments.userName) />
			<cfset results.success = TRUE />
			<cfset results.message = "" />
		<cfelse>
			<cfset results.message = "Group does not exist" />
		</cfif>
	
		<cfreturn results />
	</cffunction>
	
	<cffunction access="public" name="addACLtoProject" output="false" returntype="struct" description="Adds an ACL to a project. Returns success or failure within a structure." >
		<cfargument name="projectName" type="string" required="yes" hint="The project name to manipulate." />
		<cfargument name="securityPrinciple" type="string" required="yes" hint="The user or group name to add." />
		<cfargument name="permission" type="string" required="no" default="r" hint="The permission to add. options=r,rw,[emptyString], or d (for deny)" />
		
		<cfset var permissionToSet = arguments.permission />
		<cfset var results =StructNew() />
		<cfset var tempACL =StructNew() />
		<cfset var i =0 />
		<cfset result.success = FALSE>
		<cfset result.message = "Unknown Issue" />
		
		
		<cfif permissionToSet eq 'd'>
			<cfset permissionToSet = "" />
		<cfelseif permissionToSet neq 'r' and permissionToSet neq 'rw' and permissionToSet neq ''>
			<cfset results.message = "Invalid permission added." />
			<cfreturn results />
		</cfif>			
			
		
		<cfif structKeyExists(variables.projects, arguments.projectName)>
			
			<!--- Remove Existing ACL's' --->
			<cfloop index="i" from="#ArrayLen(variables.projects[arguments.projectName]['acl'])#" to="1" step="-1">
				<cfif variables.projects[arguments.projectName]['acl'][i]['securityPrinciple'] eq arguments.securityPrinciple>
					<cfset ArrayDeleteAt(variables.projects[arguments.projectName]['acl'],i) />
				</cfif>
			</cfloop>
			
			
			<cfset tempACL['securityPrinciple'] = arguments.securityPrinciple />
			<cfset tempACL['permission'] = permissionToSet />
			<cfset ArrayAppend(variables.projects[arguments.projectName]['acl'], tempACL) />
			<cfset results.success = TRUE />
			<cfset results.message = "" />
		<cfelse>
			<cfset results.message = "Project does not exist" />
		</cfif>
	
		<cfreturn results />
	</cffunction>
	
	<cffunction access="public" name="createGroup" output="false" returntype="struct" description="Creates a group in the authz file. Returns success or failure within a structure." >
		<cfargument name="groupName" type="string" required="yes" default="" hint="The group name to create." />
		
		<cfset var results =StructNew() />
		<cfset result.success = FALSE>
		<cfset result.message = "Unknown Issue" />
		
		<cfif not structKeyExists(variables.groups, arguments.GroupName)>
			<cfset variables.groups[arguments.GroupName] = ArrayNew(1) />
			<cfset results.success = TRUE />
			<cfset results.message = "" />
		<cfelse>
			<cfset results.message = "Group already exists." />
		</cfif>
		<cfreturn results />
	</cffunction>
	
	<cffunction access="public" name="createProject" output="false" returntype="struct" description="Creates a project in the authz file. Returns success or failure within a structure." >
		<cfargument name="projectName" type="string" required="yes" default="" hint="The project name to create." />
		
		<cfset var results =StructNew() />
		<cfset result.success = FALSE>
		<cfset result.message = "Unknown Issue" />
		
		<cfif not structKeyExists(variables.projects, arguments.projectName)>
			<cfset variables.projects[arguments.projectName] = StructNew() />
			<cfset variables.projects[arguments.projectName]['acl'] = ArrayNew(1) />
			
			<cfset results.success = TRUE />
			<cfset results.message = "" />
		<cfelse>
			<cfset results.message = "Project already exists." />
		</cfif>
		<cfreturn results />
	</cffunction>
	
	<cffunction access="public" name="getGroupMembers" output="false" returntype="struct" description="Returns a list of group members." >
		<cfargument name="group" type="string" required="yes" default="" hint="The name of the group to retrieve." />
	
		<cfset var results = StructNew()>
	
		<cfif StructKeyExists(variables.groups, arguments.group)>
			<cfset results['members'] = variables.groups[arguments.group] />
			<cfset results['exists']  = TRUE />
		<cfelse>
			<cfset results['members'] = ArrayNew(1) />
			<cfset results['exists']  = FALSE />
		</cfif>
		
		<cfreturn results />
	</cffunction>
	
	<cffunction access="public" name="getGroups" output="false" returntype="array" description="Returns the list of groups defineed by authz file." >
		
		<cfreturn StructKeyArray(variables.groups) />
	</cffunction>
	
	<cffunction access="public" name="getProjectACL" output="false" returntype="struct" description="Returns a structure of project Access Control List." >
		<cfargument name="project" type="string" required="yes" default="" hint="The name of the project to retrieve." />
	
		<cfset var results = StructNew()>
	
		<cfif StructKeyExists(variables.projects, arguments.project)>
			<cfset results['acl'] = variables.projects[arguments.project]['acl'] />
			<cfset results['exists']  = TRUE />
		<cfelse>
			<cfset results['acl'] = StructNew() />
			<cfset results['exists']  = FALSE />
		</cfif>
		
		<cfreturn results />
	</cffunction>

	<cffunction access="public" name="getProjects" output="false" returntype="array" description="Returns the list of projects defineed by authz file." >
		
		<cfreturn StructKeyArray(variables.projects)>
	</cffunction>

	<cffunction access="public" name="Save" output="false" returntype="void" description="Saves a file back to disk. " >
		
		<cffile action="write" file="#variables.AuthzFileLocation#" output="#writeFileString()#" />
	</cffunction>
	
	<cffunction access="public" name="SaveAs" output="false" returntype="void" description="Saves a file back to disk as a new file. " >
		<cfargument name="AuthzFileLocation" type="string" required="no" default="" hint="The Location of the Auth File to parse." />
		
		<cffile action="write" file="#arguments.AuthzFileLocation#" output="#writeFileString()#" />
	</cffunction>
	
	<!--- PRIVATE METHODS --->
	<cffunction access="private" name="extractProjects" output="false" returntype="struct" description="Extracts Projects and permssions from authz file." >
		<cfargument name="authzFile" type="string" required="yes" dhint="The raw contents of an authz file. Without Comments." />
		
		
		<cfset var AuthzFileAsArray = ListToArray(arguments.authzFile, chr(10)) />
	
		<cfset var currentShare = "">
		<cfset var aclCount = 0>
		
		<cfset results= StructNew()>
		<cfloop index="i" from="1" to="#ArrayLen(AuthzFileAsArray)#">
			<cfif FindNoCase("[", AuthzFileAsArray[i])>
				<cfset currentShare = ReplaceList(AuthzFileAsArray[i],"[,]", ",") />
				<cfset results[currentShare] = StructNew() />
				<cfset results[currentShare]['acl'] = ArrayNew(1) />
				<cfset aclCount = 0>
			<cfelse>
				<cfif len(currentShare) gt 0>
					<cfset aclCount = aclCount + 1 />
					<cfset results[currentShare]['acl'][aclCount] = StructNew() />
					<cfset results[currentShare]['acl'][aclCount]['securityPrinciple'] = Trim(GetToken(AuthzFileAsArray[i], 1, "=")) />
					<cfset results[currentShare]['acl'][aclCount]['permission'] =  Trim(GetToken(AuthzFileAsArray[i], 2, "=")) />
				</cfif>
			
				
			</cfif>
		</cfloop>
		 
		
		<cfset StructDelete(results, "groups") />
		
		<cfreturn results />
	</cffunction>
	
	<cffunction access="private" name="stripComments" output="false" returntype="string" description="Removes comments from an auth file." >
		<cfargument name="authzFile" type="string" required="yes" hint="The raw contents of an authz file." />
	
		<cfreturn ReReplace(arguments.authzFile, "##+[^#chr(10)##chr(13)#]*\n", "", "ALL") />
	</cffunction>
		
	<cffunction access="private" name="extractGroups" output="false" returntype="struct" description="Parses an SVN File for Group Information" >
		<cfargument name="authzFile" type="string" required="yes" default="" hint="The raw contents of an authz file. Without comments." />
		
		<cfset var results = StructNew() />
		<cfset var groups = StructNew() />
		<cfset var i = 0 />
		
		<cfset groups.GroupStart = FindNoCase("[groups]", arguments.authzFile) />
		<cfset groups.GroupEnd = FindNoCase("[", arguments.authzFile, groups.GroupStart + 1) />
		<cfset groups.List = Mid(arguments.authzFile,groups.GroupStart, groups.GroupEnd-groups.GroupStart) />
		<cfset groups.Array = ListToArray(groups.List, chr(10)) />
		
		<cfloop index="i" from="1" to="#ArrayLen(groups.Array)#">
			<cfif not FindNoCase("[groups]", groups.Array[i])>
				<cfset results[Trim(GetToken(groups.Array[i], 1, "="))] = ListToArray(Trim(GetToken(groups.Array[i], 2, "="))) />
			</cfif>
		</cfloop>
		<cfreturn results />
	</cffunction>

	<cffunction access="private" name="writeFileString" output="false" returntype="string" description="Write file back to string format." >

		<cfset var FileOutput = "" />
		
		<cfset fileOutput = fileOutput.concat("[groups]" & Chr(10)) />
		
		<cfloop collection="#variables.groups#" item="group">
			<cfset fileOutput = fileOutput.concat("#group# = #ArrayToList(variables.groups[group])#" & Chr(10)) />
		</cfloop>
		
		<cfset fileOutput = fileOutput.concat(Chr(10)) />
		
		
		<cfloop collection="#variables.projects#" item="project">
			<cfset fileOutput = fileOutput.concat("[#project#]" & Chr(10)) />
			
			<cfloop index="i" from="1" to="#ArrayLen(variables.projects[project]['acl'])#">
				<cfset fileOutput = fileOutput.concat("#variables.projects[project]['acl'][i]['securityPrinciple']# = #variables.projects[project]['acl'][i]['permission']#" & Chr(10)) />
			</cfloop>
			<cfset fileOutput = fileOutput.concat(Chr(10)) />
		</cfloop>
	
		<cfreturn fileOutput />
	</cffunction>

</cfcomponent>