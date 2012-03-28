<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<cfset vars.SebFormAttributes.CFC_Method = "placeOrder">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>