<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("StarterCart")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset vars.Title = "Products">
	<cfset vars.qProducts = variables.StarterCart.Products.getProducts()>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>