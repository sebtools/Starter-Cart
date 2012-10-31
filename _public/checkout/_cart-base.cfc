<cfcomponent displayname="Base Cart Controller" extends="_config.PageController" output="no">

<cfset loadExternalVars("StarterCart,Framework")>
<cfset loadExternalVars(varlist="SessionMgr",skipmissing=true)>
<cfset variables.sApplicationSettings = Application.getApplicationSettings()>

<cfset formExpirationDateHack()>
<cfset variables.Framework.Config.paramSetting("Cart_CartType","multi-page")>
<cfset variables.steps = "cart-items.cfm,cart-addresses.cfm,cart-payment.cfm">
<cfset variables.ShopPage = "/products/">
<cfset variables.ShopText = "Continue Shopping">

<cfset variables.oCart = getSessionCart()>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset URL.id = getOrderID()>
	<cfset vars.CustomerID = getCustomerID()>
	
	<cfset vars.Title = "Cart">
	<cfset vars.currpage = ListLast(CGI.SCRIPT_NAME,"/")>
	<cfset vars.ShopPage = variables.ShopPage>
	<cfset vars.ShopText = variables.ShopText>
	<cfset vars.steps = variables.steps>
	<cfset vars.step = getStepNum(vars.currpage)>
	<!---<cfset vars.qOrder = getOrder()>--->
	<cfset vars.qOrder = getOrderData()>
	<cfset vars.qOrderItems = getOrderItems()>
	<cfset vars.oCart = variables.oCart>
	<cfset vars.StarterCart = variables.StarterCart>
	<!---<cfset vars.isDiscountable = variables.StarterCart.hasDiscounts()>--->
	
	
	<cfif vars.step GT 0 OR vars.currpage EQ "cart.cfm">
		<cfif NOT vars.qOrderItems.RecordCount>
			<cfset go(variables.ShopPage)>
		</cfif>
	</cfif>
	
	<!--- Don't show the review page unless the order has been completed --->
	<cfif vars.currpage NEQ "cart-review.cfm" AND vars.qOrder.isCompleted>
		<cfset go("cart-review.cfm")>
	</cfif>
	
	<cfset vars.isReview = false>
	
	<cfscript>
	vars.SebFormAttributes = StructNew();
	vars.SebFormAttributes.pkfield = "OrderID";
	vars.SebFormAttributes.CFC_Component = This;
	vars.SebFormAttributes.CatchErrTypes = "StarterCart";
	vars.SebFormAttributes.query = "qOrder";
	vars.SebFormAttributes.forward = getNextPage(vars.currpage);
	
	if( StructKeyExists(Form, "submit") ) {
		if( Form.submit EQ "Update Cart" ) {
			vars.SebFormAttributes.forward = vars.currpage;
		}
		if (
				( StructKeyExists(Form, "DiscountCode") AND Len(Form.DiscountCode) )
			OR	FindNoCase("qty_",Form.FieldNames)
		) {
			vars.SebFormAttributes.CFC_Method = "updateCart";
		}
	}
	
	vars.sebFields = StructNew();
	vars.sebFields["StateProvinceID"] = StructNew();
	vars.sebFields["StateProvinceID"]["CFC_Component"] = variables.StarterCart.StateProvinces;
	vars.sebFields["Bill_StateProvinceID"] = StructNew();
	vars.sebFields["Bill_StateProvinceID"]["CFC_Component"] = variables.StarterCart.StateProvinces;
	vars.sebFields["Ship_StateProvinceID"] = StructNew();
	vars.sebFields["Ship_StateProvinceID"]["CFC_Component"] = variables.StarterCart.StateProvinces;
	</cfscript>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getSessionCart" access="public" returntype="any" output="false" hint="I return the cart component for the current session.">
	
	<cfset var oResult = 0>
	
	<cfif sApplicationSettings.SessionManagement>
		<cfif
				NOT StructKeyExists(Session,"oCart")
			OR	variables.StarterCart.initialized() GT Session.oCart.initialized()
			OR	getOrderID() NEQ Session.oCart.getOrderID()
			OR	false
		>
			<cfset Session.oCart = CreateObject("component","CartSession").init(variables.StarterCart,getOrderID())>
		</cfif>
		<cfset oResult = Session.oCart>
	<cfelse>
		<cfset oResult = CreateObject("component","CartSession").init(variables.StarterCart,getOrderID())>
	</cfif>
	
	<cfreturn oResult>
</cffunction>

<cffunction name="killSessionCart" access="public" returntype="void" output="false">
	
	<cfif sApplicationSettings.SessionManagement AND StructKeyExists(Session,"oCart")>
		<cfset StructDelete(Session,"ocart")>
	</cfif>
	<cfset StructDelete(variables,"oCart")>
	
</cffunction>

<cffunction name="formExpirationDateHack" access="public" returntype="any" output="false" hint="">

	<!--- Kind of hacking up a custom month/year field --->
	<cfif StructKeyExists(Form,"ccexpmonth") AND StructKeyExists(Form,"ccexpyear")>
		<cfset Form.ccexpire = "#Form.ccexpmonth##Form.ccexpyear#">
		<cfif Len(Form.ccexpire) NEQ 6>
			<cfset Form.ccexpire = "">
		</cfif>
	</cfif>

</cffunction>

<cffunction name="addItem" access="remote" returntype="numeric" output="false" hint="I add an item to a user's cart/order and return the OrderItemID for the added item.">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="Quantity" type="numeric" default="1">
	
	<cfset var sProduct = getProductData(arguments.ProductIdentifier,Int(arguments.Quantity))>
	
	<cfreturn variables.oCart.addItem(argumentCollection=sProduct)>
</cffunction>

<cffunction name="changeQuantity" access="remote" returntype="void" output="false" hint="I change the quantity of the given item from the user's cart.">
	<cfargument name="OrderItemID" type="numeric" required="yes">
	<cfargument name="Quantity" type="numeric" required="yes">
	
	<cfset variables.oCart.changeQuantity(OrderItemID=arguments.OrderItemID,Quantity=arguments.Quantity)>
	
</cffunction>

<cffunction name="closeOrder" access="remote" returntype="any" output="false" hint="I close the current order.">
	
	<cfset variables.SessionMgr.deleteVar("OrderID")>
	
</cffunction>

<cffunction name="getOrder" access="remote" returntype="query" output="false" hint="I return a recordset of cart/order record.">
	
	<cfreturn variables.oCart.getOrder()>
</cffunction>

<cffunction name="getOrderData" access="remote" returntype="query" output="false" hint="I return a recordset of the cart/order record and associated information.">
	
	<cfreturn variables.oCart.getOrderData()>
</cffunction>

<cffunction name="removeItem" access="remote" returntype="void" output="false" hint="I remove the given product from the user's cart/order.">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	
	<cfset variables.oCart.removeItem(ProductIdentifier=arguments.ProductIdentifier)>
	
</cffunction>

<cffunction name="setDiscount" access="remote" returntype="void" output="false" hint="I attempt to apply a discount to the order.">
	<cfargument name="DiscountCode" type="string" required="yes">
	
	<cfset variables.oCart.setDiscount(DiscountCode=arguments.DiscountCode)>
	
</cffunction>

<cffunction name="getOrderItems" access="remote" returntype="query" output="false" hint="I return a recordset of the items in this cart/order.">
	
	<cfreturn variables.oCart.getOrderItems()>
</cffunction>

<cffunction name="hasOpenOrder" access="remote" returntype="boolean" output="false" hint="I indicate whether or not the current user has an open order/cart.">
	
	<cfreturn variables.SessionMgr.exists("OrderID")>
</cffunction>

<cffunction name="getFieldsStruct" access="public" returntype="struct" output="no">
	
	<cfset var sFields = variables.StarterCart.Addresses.getFieldsStruct(argumentCollection=arguments)>
	<cfset var key = "">
	<cfset var sResult = StructNew()>
	
	<!--- Add Order fields to results struct --->
	<cfset sFields = variables.StarterCart.Orders.getFieldsStruct(argumentCollection=arguments)>
	<cfset StructAppend(sResult,sFields,"yes")>
	
	<!--- Add address fields to results struct --->
	<cfset sFields = variables.StarterCart.Addresses.getFieldsStruct(argumentCollection=arguments)>
	
	<cfloop collection="#sFields#" item="key">
		<cfset sResult["Bill_#key#"] = sFields[key]>
		<cfset sResult["Ship_#key#"] = sFields[key]>
	</cfloop>
	
	<cfreturn sResult>
</cffunction>

<cffunction name="getNextPage" access="public" returntype="string" output="false" hint="I return the page that comes after the given page in the checkout process.">
	<cfargument name="page" type="string" required="yes">
	
	<cfset var result = "cart-review.cfm">
	<cfset var step = getStepNum(arguments.page)>
	
	<cfif step GT 0 AND step LT ListLen(variables.steps)>
		<cfset result = ListGetAt(variables.steps,step+1)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getOrderID" access="public" returntype="any" output="false" hint="I return the OrderID for the current user's order/cart.">
	
	<cfset var result = 0>
	
	<cfif hasOpenOrder()>
		<cfset result = variables.SessionMgr.getValue("OrderID")>
	<cfelse>
		<cfset result = variables.StarterCart.createOrder()>
		<cfset variables.SessionMgr.setValue("OrderID",result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getProductData" access="public" returntype="struct" output="false" hint="I return a structure of the product information for the given product.">
	<cfargument name="ProductIdentifier" type="string" required="yes" hint="A unique value for a product.">
	<cfargument name="Quantity" type="numeric" default="1" hint="The quantity to be returned in the structure.">
	
	<cfset var sResult = StructNew()>
	
	<cftry>
		<cfinvoke method="getProductData_#ListFirst(arguments.ProductIdentifier,':')#" returnvariable="sResult">
			<cfinvokeargument name="prodident" value="#ListRest(arguments.ProductIdentifier,':')#">
			<cfinvokeargument name="Quantity" value="#arguments.Quantity#">
		</cfinvoke>
	<cfcatch>
		<cfthrow message="No such product found." detail="Check _cart.cfc:getProductData()" type="cart">
	</cfcatch>
	</cftry>
	
	<cfset sResult["ProductIdentifier"] = arguments.ProductIdentifier>
	<cfset sResult["Quantity"] = arguments.Quantity>
	
	<cfreturn sResult>
</cffunction>

<cffunction name="getStepNum" access="public" returntype="string" output="false" hint="I return the step number for the given page.">
	<cfargument name="page" type="string" required="yes">
	
	<cfreturn ListFindNoCase(variables.steps,ListFirst(arguments.page,"/"))>
</cffunction>

<cffunction name="placeOrder" access="public" returntype="void" output="no">
	
	<cfset updateCart(argumentCollection=arguments)>
	<cfset saveAddresses(argumentCollection=arguments)>
	<cfset processPayment(argumentCollection=arguments)>
	
	<cfset closeOrder()>
	
</cffunction>

<cffunction name="processPayment" access="public" returntype="void" output="no">
	
	<cfinvoke component="#variables.oCart#" method="processPayment">
		<!---<cfinvokeargument name="OrderID" value="#getOrderID()#">--->
		<cfinvokeargument name="CreditCardID" value="#arguments.CreditCardID#">
		<cfinvokeargument name="cc" value="#arguments.ccnum#">
		<cfinvokeargument name="ccv" value="#arguments.ccv#">
		<cfinvokeargument name="year" value="#arguments.ccexpyear#">
		<cfinvokeargument name="month" value="#arguments.ccexpmonth#">
	</cfinvoke>
	
</cffunction>

<cffunction name="saveAddresses" access="public" returntype="void" output="no">
	
	<cfset var customerid = getCustomerID()>
	<cfset var orderid = getOrderID()>
	<cfset var sBilling = StructNew()>
	<cfset var sShipping = StructNew()>
	<cfset var sOrder = StructNew()>
	<cfset var key = "">
	
	<cfscript>
	sOrder["OrderID"] = orderid;
	sOrder["total"] = false;
	if ( StructKeyExists(arguments,"ship2billing") AND arguments.ship2billing IS true ) {
		sOrder["ship2billing"] = true;
	} else {
		sOrder["ship2billing"] = false;
	}
	//Billing information
	sBilling["OrderID"] = orderid;
	for ( key in arguments ) {
		if ( ListLen(key,"_") EQ 2 AND ListFirst(key,"_") EQ "Bill" ) {
			sBilling[ListLast(key,"_")] = arguments[key];
		}
	}
	//Shipping information
	sShipping["OrderID"] = orderid;
	if ( StructKeyExists(arguments,"ship2billing") AND arguments.ship2billing IS true ) {
		sShipping = StructCopy(sBilling);
	} else {
		for ( key in arguments ) {
			if ( ListLen(key,"_") EQ 2 AND ListFirst(key,"_") EQ "Ship" ) {
				sShipping[ListLast(key,"_")] = arguments[key];
			}
		}
	}
	if( customerid ) {
		sBilling["CustomerID"] = customerid;
		if(StructCount(sShipping)) {
			sShipping["CustomerID"] = customerid;
		}
		sOrder["CustomerID"] = customerid;
	}
	
	if( StructKeyExists(Arguments, "Email") AND Len(Trim(Arguments.Email)) ) {
		sBilling["Email"] = Arguments.Email;
	}
	
	if(StructKeyExists(Arguments, "Phone") AND Len(Trim(Arguments.Phone))) {
		sBilling["Phone"] = Arguments.Phone;
	}
	
	variables.oCart.setBuyer(argumentCollection=sBilling);
	if( StructCount(sShipping) ) {
		variables.oCart.setRecipient(argumentCollection=sShipping);
	}
	variables.oCart.saveOrder(argumentCollection=sOrder);
	</cfscript>
		
	</cffunction>
	
	<cffunction name="updateCart" access="public" returntype="void" output="no">
	
	<cfset var qOrderItems = getOrderItems()>
	<cfset var sQuantities = StructNew()>
	<cfset var key = "">
	
	<cfloop query="qOrderItems">
		<cfset sQuantities[OrderItemID] = Quantity>
	</cfloop>
	
	<cfscript>
	for ( key in arguments ) {
		if ( ListLen(key,"_") EQ 2 AND ListFirst(key,"_") EQ "qty" AND isNumeric(ListLast(key,"_")) AND isNumeric(arguments[key])  ) {
			if ( arguments[key] NEQ sQuantities[ListLast(key,"_")] ) {
				changeQuantity(ListLast(key,"_"),arguments[key]);
			}
		}
	}
	
	if ( StructKeyExists(arguments,"DiscountCode") AND Len(Trim(arguments.DiscountCode)) ) {
		setDiscount(arguments.DiscountCode);
	}
	</cfscript>
	
</cffunction>

<cffunction name="getproductData_prod" access="private" returntype="any" output="false" hint="I return a structure of the product information for the given product using StartCart's built-in products.">
	<cfargument name="prodident" type="string" required="yes">
	<cfargument name="Quantity" type="numeric" default="1">
	
	<cfset var sResult = variables.StarterCart.Products.getCartItemStruct(arguments.prodident)>
	
	<cfset sResult["Quantity"] = arguments.Quantity>
	
	<cfreturn sResult>
</cffunction>

</cfcomponent>