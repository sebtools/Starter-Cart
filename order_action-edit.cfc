<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("OrderActions,Notices",".StarterCart",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Order Action","edit")>
	
	<cfset require("URL.id","numeric","order-list.cfm")>
	
	<cfset vars.Title = "Order Action">
	<cfset vars.qOrderAction = variables.OrderActions.getOrderAction(URL.id)>
	<cfset vars.qOrderActionMessages = variables.OrderActions.getOrderActionMessages(URL.id)>
	<cfset vars.hasActionNotice = variables.Notices.hasActionNotice(vars.qOrderAction.Action)>
	
	<cfset vars.Title = "View #vars.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>