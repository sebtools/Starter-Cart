<cfcomponent extends="_config.PageController" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	<cfargument name="VariablesScope" type="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = arguments.VariablesScope>
	
	<cfset StructAppend(vars.attributes,vars.Caller,"no")>
	<cfset StructAppend(vars,vars.attributes,"no")>
	<cfparam name="vars.attributes.isReview" type="boolean" default="false">
	<cfparam name="vars.attributes.qOrder" type="query">
	<cfset StructAppend(vars,vars.attributes,"no")>
	
	<cfset vars.isShipRequired = NOT StructKeyExists(Form,"ship2billing")>
	
	<cfif vars.isReview>
		<cfset vars.BillingAddress = "">
		<cfset vars.ShippingAddress = "">
		<cfif vars.qOrder.BillingAddressID GT 0>
			<cfset vars.BillingAddress = vars.StarterCart.Addresses.getAddressHTML(vars.qOrder.BillingAddressID)>
		</cfif>
		<cfif vars.qOrder.ShippingAddressID GT 0>
			<cfset vars.ShippingAddress = vars.StarterCart.Addresses.getAddressHTML(vars.qOrder.ShippingAddressID)>
		</cfif>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>