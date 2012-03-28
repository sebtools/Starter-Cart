<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<cfscript>
	vars.SebFormAttributes.CFC_Method = "processPayment";
	vars.isReview = true;
	</cfscript>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>