<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<!--- Don't show the review page unless the order has been completed --->
	<cfif NOT vars.qOrder.isCompleted>
		<cfset go(ListFirst(variables.steps))>
	</cfif>
	
	<cfscript>
	//Submitting the form shouldn't do anything on this page
	StructDelete(vars.SebFormAttributes,"CFC_Component");
	vars.Title = "Order Review";
	vars.isReview = true;
	</cfscript>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>