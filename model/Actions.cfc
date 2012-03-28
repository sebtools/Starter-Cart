<cfcomponent displayname="Actions" extends="com.sebtools.Records" output="no">

<cffunction name="getStatuses" access="public" returntype="query" output="no" hint="I return all of the Actions.">
	
	<cfset arguments.HasStatus = true>
	
	<cfreturn getRecords(argumentCollection=arguments)>
</cffunction>

</cfcomponent>