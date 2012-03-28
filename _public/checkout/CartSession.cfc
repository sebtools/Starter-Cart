<cfcomponent displayname="Cart Session" output="no" doc:Groups="Initialization,Order Processing,Utility" hint="I am a cart session (instantiate into Session scope) and facade for StarterCart.cfc. I can call any method on StarterCart.cfc and automatically include the OrderID into the arguments.">

<cffunction name="init" access="public" returntype="any" output="no" doc:Group="Initialization" hint="I initialize and return this component.">
	<cfargument name="StarterCart" type="any" required="yes">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<cfset variables.StarterCart = arguments.StarterCart>
	<cfset variables.OrderID = arguments.OrderID>
	<cfset variables.DateInitialized = now()>
	
	<cfset resetInstance()>
	
	<cfreturn This>
</cffunction>

<cffunction name="initialized" access="public" returntype="date" output="no" doc:Group="Initialization" hint="I return the date that this instance of CartSession was instantiated (used to compare with method of same name on StarterCart.cfc so this one can be reloaded if StarterCart has changed since then).">
	<cfreturn variables.DateInitialized>
</cffunction>

<cffunction name="getOrderID" access="public" returntype="numeric" output="no" doc:Group="Order Processing" hint="I return thie OrderID for this instance of CartSession.">
	<cfreturn variables.OrderID>
</cffunction>

<cffunction name="isCompleted" access="public" returntype="boolean" output="no" doc:Group="Order Processing" hint="I indicate if this order has been completed.">
	
	<cfset var result = false>
	<cfset var qOrder = getOrderData()>
	
	<cfif qOrder.isCompleted IS true>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="resetInstance" access="public" returntype="void" doc:Group="Utility" output="no" hint="I reset the instance data for this instance of CartSession (useful if an outside process might have changed some data).">
	<cfset variables.instance = StructNew()>
</cffunction>

<cffunction name="removeItem" access="public" returntype="void" output="false" doc:Group="Order Processing" hint="I remove the given product from the user's cart/order.">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	
	<cfinvoke component="#variables.StarterCart#" method="removeItem">
		<cfinvokeargument name="OrderID" value="#variables.OrderID#">
		<cfinvokeargument name="ProductIdentifier" value="#arguments.ProductIdentifier#">
	</cfinvoke>
	
	<cfset resetInstance()>
	
</cffunction>

<cffunction name="changeQuantity" access="public" returntype="void" output="false" doc:Group="Order Processing" hint="I change the quantity of the given item from the user's cart.">
	<cfargument name="OrderItemID" type="numeric" required="yes">
	<cfargument name="Quantity" type="numeric" required="yes">
	
	<cfinvoke component="#variables.StarterCart#" method="changeQuantity">
		<cfinvokeargument name="OrderID" value="#variables.OrderID#">
		<cfinvokeargument name="OrderItemID" value="#arguments.OrderItemID#">
		<cfinvokeargument name="Quantity" value="#arguments.Quantity#">
	</cfinvoke>
	
	<cfset resetInstance()>
	
</cffunction>

<cffunction name="setDiscount" access="public" returntype="void" output="false" doc:Group="Order Processing" hint="I attempt to apply a discount to the order.">
	<cfargument name="DiscountCode" type="string" required="yes">
	
	<cfinvoke component="#variables.StarterCart#" method="setDiscount">
		<cfinvokeargument name="OrderID" value="#variables.OrderID#">
		<cfinvokeargument name="DiscountCode" value="#arguments.DiscountCode#">
	</cfinvoke>
	
	<cfset resetInstance()>
	
</cffunction>

<cffunction name="addItem" access="public" returntype="numeric" output="false" doc:Group="Order Processing" hint="I add an item to a user's cart/order and return the OrderItemID for the added item.">
	
	<cfset var result = 0>
	
	<cfset arguments["OrderID"] = variables.OrderID>
	
	<cfset result = variables.StarterCart.addItem(argumentCollection=arguments)>
	
	<cfset resetInstance()>
	
	<cfreturn result>
</cffunction>

<cffunction name="getOrder" access="public" returntype="query" output="false" doc:Group="Order Processing" hint="I return a recordset of cart/order record.">
	
	<cfif NOT StructKeyExists(variables.instance,"qOrder")>
		<cfset variables.instance.qOrder = variables.StarterCart.Orders.getOrder(OrderID=variables.OrderID)>
	</cfif>
	
	<cfreturn variables.instance.qOrder>
</cffunction>

<cffunction name="getOrderData" access="public" returntype="query" output="false" doc:Group="Order Processing" hint="I return a recordset of the cart/order record and associated information.">
	
	<cfif NOT StructKeyExists(variables.instance,"qOrderData")>
		<cfset variables.instance.qOrderData = getOrderData_Internal()>
	</cfif>
	
	<cfreturn variables.instance.qOrderData>
</cffunction>

<cffunction name="getOrderItems" access="public" returntype="query" output="false" doc:Group="Order Processing" hint="I return a recordset of the items in this cart/order.">
	
	<cfset var qOrderItems = 0>
	
	<cfif NOT StructKeyExists(variables.instance,"qOrderItems")>
		<cfset variables.instance.qOrderItems = variables.StarterCart.OrderItems.getOrderItems(OrderID=variables.OrderID)>
	</cfif>
	
	<cfreturn variables.instance.qOrderItems>
</cffunction>

<cffunction name="saveOrder" access="public" returntype="void" doc:Group="Order Processing" output="no" hint="I save the order data.">
	
	<cfset variables.StarterCart.Orders.saveOrder(argumentCollection=arguments)>
	
	<cfset resetInstance()>
	
</cffunction>

<cffunction name="onMissingMethod" access="public" returntype="any" output="false" doc:Group="Utility" hint="I call any method on StarterCart and add the OrderID argument. I return any data returned by the method.">

	<cfset var result = 0>
	<cfset var method = arguments.missingMethodName>
	<cfset var args = arguments.missingMethodArguments>
	
	<cfset args["OrderID"] = variables.OrderID>
	
	<cfinvoke
		returnvariable="result"
		component="#variables.StarterCart#"
		method="#method#"
		argumentCollection="#args#"
	>
	
	<cfif Left(method,3) NEQ "get">
		<cfset resetInstance()>
	</cfif> 
	
	<cfif isDefined("result")><cfreturn result></cfif>
</cffunction>

<cffunction name="getOrderData_Internal" access="private" returntype="query" output="false" hint="">
	
	<cfset var sOrder = variables.StarterCart.getOrderData(OrderID=variables.OrderID)>
	<cfset var qOrder = QueryNew(StructKeyList(sOrder))>
	<cfset var key = "">
	
	<cfset QueryAddRow(qOrder)>
	
	<cfloop collection="#sOrder#" item="key">
		<cfif StructKeyExists(sOrder,key) AND isSimpleValue(sOrder[key])>
			<cfset QuerySetCell(qOrder,key,sOrder[key])>
		</cfif>
	</cfloop>
	
	<cfreturn qOrder>
</cffunction>

</cfcomponent>