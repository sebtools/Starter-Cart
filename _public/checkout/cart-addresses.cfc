<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<cfif NOT vars.qOrderItems.RecordCount>
		<cfset go(variables.ShopPage)>
	</cfif>
	
	<cfset vars.SebFormAttributes.CFC_Method = "saveAddresses">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>