<cfcomponent displayname="Notices" output="no">

<cffunction name="init" access="public" returntype="any" output="false" hint="">
	<cfargument name="StarterCart" type="any" required="yes">
	
	<cfset variables.StarterCart = arguments.StarterCart>
	
	<cfif StructKeyExists(variables.StarterCart,"NoticeMgr")>
		<cfset loadDefaultNotices()>
		<cfset loadCustomNotices()>
	</cfif>
	
	<cfreturn This>
</cffunction>

<cffunction name="hasActionNotice" access="public" returntype="boolean" output="false" hint="">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset var result = false>
	<cfset var method = "sendNotice_#ActionMethod(arguments.Action)#">
	
	<cfif StructKeyExists(variables.StarterCart,"NoticeMgr") AND StructKeyExists(This,method)>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="sendNotice" access="public" returntype="boolean" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset var result = false>
	<cfset var method = "sendNotice_#ActionMethod(arguments.Action)#">
	
	<cfif hasActionNotice(arguments.Action)>
		<cftry>
			<cfinvoke returnvariable="result" component="#This#" method="#method#" argumentcollection="#arguments#"></cfinvoke>
		<cfcatch>
			<cfset result = false>
		</cfcatch>
		</cftry>
	<cfelse>
		<cfset result = false>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="ActionMethod" access="public" returntype="string" output="false" hint="">
	<cfargument name="Action" type="string" required="yes">
	
	<cfset var regex = "[^a-z0-9]">
	
	<cfreturn ReReplaceNoCase(arguments.Action,regex,"","ALL")>
</cffunction>

<cffunction name="loadCustomNotices" access="private" returntype="any" output="false" hint="">

</cffunction>

<cffunction name="loadDefaultNotices" access="private" returntype="any" output="false" hint="">

<!---<cf_NoticeMgr
	action="addHTML"
	Component="#This#"
	Name="Cart: Order Complete"
	Subject="Shopping Cart Order Completed"
	DataKeys=""
><cfoutput><html><body>

</body></html></cfoutput></cf_NoticeMgr>--->

</cffunction>

</cfcomponent>