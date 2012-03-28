<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("StarterCart")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset require("URL.id","numeric","products.cfm")>
	
	<cfset vars.qProduct = variables.StarterCart.Products.getProduct(URL.id)>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>