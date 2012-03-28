<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = super.loadData()>
	
	<cfset vars.page = "cart.cfm">
	<cfif variables.Framework.Config.getSetting("Cart_CartType") EQ "multi-page">
		<cfset vars.page = ListFirst(variables.steps)>
	</cfif>
	
	<cfset go(vars.page)>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>