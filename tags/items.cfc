<cfcomponent extends="_config.PageController" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	<cfargument name="VariablesScope" type="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = arguments.VariablesScope>
	
	<cfset StructAppend(vars.attributes,vars.Caller,"no")>
	<cfset StructAppend(vars,vars.attributes,"no")>
	<cfparam name="vars.attributes.isDiscountable" type="boolean" default="#Application.StarterCart.hasDiscounts()#">
	<cfparam name="vars.attributes.isAdmin" type="boolean" default="false">
	<cfparam name="vars.attributes.isReview" type="boolean" default="false">
	<cfparam name="vars.attributes.qOrder" type="query">
	<cfparam name="vars.attributes.qOrderItems" type="query">
	<cfset StructAppend(vars,vars.attributes,"no")>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>