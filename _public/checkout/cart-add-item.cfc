<cfcomponent extends="_cart" output="no">

<cfset variables.oCart = getSessionCart()>
<cfset StructAppend(Form,URL)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = super.loadData()>
	
	<cfset default("Form.ProductIdentifier","string","")>
	<cfset default("Form.Quantity","numeric",1)>
	<cfset default("Form.CartType","string",variables.Framework.Config.getSetting("Cart_CartType"))>
	
	<cfif NOT Len(Form.ProductIdentifier)>
		<cfthrow message="ProductIdentifier is required">
	</cfif>
	
	<cfif Form.CartType NEQ "multi-page">
		<cfset Form.CartType = "single-page">
	</cfif>
	
	<cfset addItem(Form.ProductIdentifier,Form.Quantity)>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getForward" access="public" returntype="string" output="false" hint="">
	
	<cfset var result = "cart.cfm">
	
	<cfif Form.CartType EQ "multi-page">
		<cfset result = ListFirst(variables.steps)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSessionCart" access="public" returntype="any" output="false">
	
	<!--- Close old order to start new one --->
	<cfif hasOpenOrder() AND variables.StarterCart.Orders.isCompleted(getOrderID())>
		<cfset closeOrder()>
		<cfset killSessionCart()>
	</cfif>
	
	<cfreturn super.getSessionCart()>
</cffunction>

</cfcomponent>