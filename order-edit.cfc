<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("StarterCart")>
<cfset loadExternalVars("Orders,Customers,Discounts,Shippers,OrderItems,Addresses","StarterCart",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<!--- local variables: local for internal data, vars will be returned as variables scope on the page --->
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Order","edit")>
	
	<!--- Param URL variables --->
	<cfset require("URL.id","numeric","order-list.cfm")>
	
	<!--- Set default values for vars variables --->
	<cfset vars.StarterCart = variables.StarterCart>
	<cfset vars.qOrder = variables.Orders.getOrder(URL.id)>
	<cfset vars.qOrderItems = variables.OrderItems.getOrderItems(OrderID=URL.id)>
	<cfset vars.qPossibleActions = getPossibleActions(vars.qOrder.Statuses)>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getPossibleActions" access="public" returntype="query" output="no" hint="I get the statuses that are possible for the given order">
	<cfargument name="Statuses" type="string" required="yes">
	
	<cfset var qActions = QueryNew("Action")>
	
	<cfif NOT ListFindNoCase(arguments.Statuses,"Shipped")>
		<cfset QueryAddRow(qActions)>
		<cfset QuerySetCell(qActions,"Action","Ship")>
		<cfif NOT ListFindNoCase(arguments.Statuses,"Cancelled")>
			<cfset QueryAddRow(qActions)>
			<cfset QuerySetCell(qActions,"Action","Cancel")>
		</cfif>
	</cfif>
	
	<cfif ListFindNoCase(arguments.Statuses,"Shipped") AND NOT ListFindNoCase(arguments.Statuses,"Returned")>
		<cfset QueryAddRow(qActions)>
		<cfset QuerySetCell(qActions,"Action","Return")>
	</cfif>
	
	<cfreturn qActions>
</cffunction>

</cfcomponent>