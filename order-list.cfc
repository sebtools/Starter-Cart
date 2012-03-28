<cfcomponent extends="_config.PageController" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<cfset vars.sFilters["isPaid"] = true>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>