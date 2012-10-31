<cfcomponent displayname="Starter Cart" extends="com.sebtools.ProgramManager" doc:Groups="Initialization,Order Processing,Administration,Utility" hint="I manage all of the functionality for Starter Cart. Note that Starter Cart allows external (or internal) management of products which causes some increased API complexity in return for the extra flexibility.">

<cfset variables.prefix = "cart">

<cffunction name="init" access="public" returntype="any" output="false" doc:Group="Initialization" hint="I initialize and return this component.">
	<cfargument name="Manager" type="any" required="yes">
	<cfargument name="cfpayment" type="any" required="yes">
	<cfargument name="NoticeMgr" type="any" required="no">
	<cfargument name="Scheduler" type="any" required="no">
	<cfargument name="ErrorEmail" type="string" required="no">
	
	<cfset initInternal(argumentCollection=arguments)>
	<cfset variables.DateInitialized = now()>
	
	<cfreturn This>
</cffunction>

<cffunction name="initialized" access="public" returntype="date" output="false" doc:Group="Initialization" hint="I return the date that this instance of StarterCart was instantiated.">
	<cfreturn variables.DateInitialized>
</cffunction>

<cffunction name="addItem" access="public" returntype="numeric" output="false" doc:Group="Order Processing" hint="I add an item to a user's cart/order and return the OrderItemID for the added item.">
	<cfargument name="OrderID" type="string" required="yes" hint="The OrderID to which the item should be added. If zero, StarterCart will create a new order for this item.">
	<cfargument name="ProductIdentifier" type="string" required="yes" hint="A unique identifier for the product being purchased.">
	<cfargument name="ProductName" type="string" required="yes" hint="The name of the product as it should appear in the cart.">
	<cfargument name="Price" type="numeric" required="yes" hint="The per-unit price of the product (Starter Cart will not verify the price against the price of the product).">
	<cfargument name="Quantity" type="numeric" default="1" hint="The number of items of this product being added.">
	<cfargument name="ProductInfo" type="string" required="no" hint="HTML for additional information about this item that should display in the cart (this can include a brief description or options chosen, for example).">
	<cfargument name="LinkAdmin" type="string" required="no" hint="The URL for administering this product to display in the site administration area.">
	<cfargument name="LinkPublic" type="string" required="no" hint="The URL for the public page for this product to display to the user.">
	
	<cfset var qOrderitems = 0>
	<cfset var sOrder = StructNew()>
	<cfset var sItem = 0>
	
	<!--- Create order, if not already existing --->
	<cfif NOT ( isNumeric(arguments.OrderID) AND arguments.OrderID GT 0 )>
		<cftimer type="debug" label="Create Order">
			<cfset arguments.OrderID = createOrder( arguments.Price * Int(arguments.Quantity) )>
		</cftimer>
	<cfelse>
		<cftimer type="debug" label="Record Update Action">
			<cfset recordAction(arguments.OrderID,"Update")>
		</cftimer>
	</cfif>
	
	<!--- Add item to order --->
	<cftimer type="debug" label="Save Order Item">
		<cfset variables.OrderItems.saveOrderItem(argumentCollection=arguments)>
	</cftimer>
	
	<cftimer type="debug" label="Update Order Total">
		<cfset updateOrderTotal(arguments.OrderID)>
	</cftimer>
	
	<cfreturn arguments.OrderID>
</cffunction>

<cffunction name="changeQuantity" access="public" returntype="void" output="false" doc:Group="Order Processing" hint="I change the quantity of an order item.">
	<cfargument name="OrderID" type="numeric" required="yes" hint="The OrderID for the order being changed.">
	<cfargument name="OrderItemID" type="numeric" required="yes" hint="The OrderItemID for the item whose quantity is being changed.">
	<cfargument name="Quantity" type="numeric" required="yes" hint="The new quantity for the item. A quantity of zero will remove the item from the cart.">
	
	<cfset var qItem = variables.OrderItems.getOrderItem(OrderItemID=arguments.OrderItemID,fieldlist="OrderItemID,Quantity")>
	<cfset var sItem = StructNew()>
	
	<cfset sItem["OrderItemID"] = arguments.OrderItemID>
	<cfset sItem["OrderID"] = arguments.OrderID>
	<cfset sItem["Quantity"] = arguments.Quantity>
	
	<cfif qItem.Quantity NEQ sItem.Quantity>
		<cfset variables.OrderItems.saveOrderItem(argumentCollection=sItem)>
	</cfif>
	
	<cfset updateOrderTotal(arguments.OrderID)>
	
</cffunction>

<cffunction name="getBillingAddress" access="public" returntype="query" output="false" doc:Group="Order Processing" hint="I return a recordset of the billing address for the order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<cfset var qOrder = variables.Orders.getOrder(OrderID=arguments.OrderID,fieldlist="BillingAddressID")>
	<cfset var qBillingAddress = variables.Addresses.getAddress(AddressID=Val(qOrder.BillingAddressID))>
	
	<cfreturn qBillingAddress>
</cffunction>

<cffunction name="getShippingAddress" access="public" returntype="query" output="false" doc:Group="Order Processing" hint="I return a recordset of the billing address for the order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<cfset var qOrder = variables.Orders.getOrder(OrderID=arguments.OrderID,fieldlist="ShippingAddressID")>
	<cfset var qShippingAddress = variables.Addresses.getAddress(AddressID=Val(qOrder.ShippingAddressID))>
	
	<cfreturn qShippingAddress>
</cffunction>

<cffunction name="getOrderData" access="public" returntype="struct" output="false" doc:Group="Order Processing" hint="I return a structure of the data for the given order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<cfset var qOrder = variables.Orders.getOrder(OrderID=arguments.OrderID)>
	<cfset var qBillAddress = 0>
	<cfset var qShipAddress = 0>
	<cfset var AddressCols = "FirstName,LastName,Address1,Address2,City,StateProvinceID,PostalCode">
	<cfset var key = "">
	<cfset var sResult = StructNew()>
	<cfset var sOrder = StructNew()>
	
	<cfloop list="#qOrder.ColumnList#" index="key">
		<cfset sOrder[key] = qorder[key][1]>
	</cfloop>
	
	<cfif qOrder.BillingAddressID GT 0>
		<cfset qBillAddress = variables.Addresses.getAddress(qOrder.BillingAddressID)>
		<cfif qBillAddress.RecordCount>
			<cfloop list="#AddressCols#" index="key">
				<cfset sOrder["Bill_#key#"] = qBillAddress[key][1]>
			</cfloop>
		</cfif>
	</cfif>
	<cfif qOrder.ShippingAddressID GT 0>
		<cfset qShipAddress = variables.Addresses.getAddress(qOrder.ShippingAddressID)>
		<cfif qShipAddress.RecordCount>
			<cfloop list="#AddressCols#" index="key">
				<cfset sOrder["Ship_#key#"] = qShipAddress[key][1]>
			</cfloop>
		</cfif>
	</cfif>
	
	<cfreturn sOrder>
</cffunction>

<cffunction name="hasDiscounts" access="public" returntype="boolean" output="false" doc:Group="Order Processing" hint="I indicate whether or not the system has any active discounts.">
	
	<cfreturn variables.Discounts.hasDiscounts()>
</cffunction>

<cffunction name="placeOrder" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I place an order in a single method call (not to be used in conjunction with other methods).">
	<cfargument name="OrderID" type="numeric" required="no">
	<cfargument name="sPayment" type="struct" required="yes" hint="A structure with a keys matching the arguments of the processPayment method (excluding OrderID)">
	<cfargument name="sBuyer" type="struct" required="yes" hint="A structure with a keys matching the arguments of the setBuyer method (excluding OrderID)">
	<cfargument name="sShippee" type="struct" required="no" hint="A structure with a keys matching the arguments of the setShippee method (excluding OrderID)">
	<cfargument name="sItem" type="struct" required="no" hint="A structure with a keys matching the arguments of the addItem method (excluding OrderID)">
	<cfargument name="aItems" type="array" required="no" hint="An array of structures each with a keys matching the arguments of the addItem method (excluding OrderID)">
	<cfargument name="DiscountCode" type="string" required="no">
	
	<cfset var ii = 0>
	
	<cfif NOT ( StructKeyExists(arguments,"sItem") OR StructKeyExists(arguments,"aItems") )>
		<cfset throwError("An order must include at least one item.")>
	</cfif>
	
	<cftransaction isolation="serializable">
		<cftry>
			<cfif NOT StructKeyExists(arguments,"OrderID")>
				<cfset arguments.OrderID = createOrder(0)>
			</cfif>
			
			<cfif StructKeyExists(arguments,"sItem")>
				<cfset arguments.sItem["OrderID"] = arguments.OrderID>
				<cfset addItem(argumentCollection=arguments.sItem)>
			</cfif>
			
			<cfif StructKeyExists(arguments,"aItems")>
				<cfloop index="ii" from="1" to="#ArrayLen(arguments.aItems)#" step="1">
					<cfset arguments.aItems[ii]["OrderID"] = arguments.OrderID>
					<cfset addItem(argumentCollection=arguments.aItems[ii])>
				</cfloop>
			</cfif>
			
			<cfif StructKeyExists(arguments,"sShippee")>
				<cfset arguments.sShippee["OrderID"] = arguments.OrderID>
				<cfset setShippee(argumentCollection=arguments.sShippee)>
			</cfif>
			
			<cfset arguments.sBuyer["OrderID"] = arguments.OrderID>
			<cfset setBuyer(argumentCollection=arguments.sBuyer)>
			
			<cfif StructKeyExists(arguments,"DiscountCode") AND Len(arguments.DiscountCode)>
				<cfset setDiscount(arguments.OrderID,arguments.DiscountCode)>
			</cfif>
		<cfcatch>
			<cftransaction action="rollback" />
		</cfcatch>
		</cftry>
		<cftransaction action="commit" />
	</cftransaction>
	
	<cfinvoke method="processPayment">
		<cfinvokeargument name="OrderID" value="#arguments.OrderID#">
		<cfinvokeargument name="cc" value="#arguments.sPayment.cc#">
		<cfinvokeargument name="ccv" value="#arguments.sPayment.ccv#">
		<cfinvokeargument name="year" value="#arguments.sPayment.year#">
		<cfinvokeargument name="month" value="#arguments.sPayment.month#">
		<cfif StructKeyExists(arguments.sPayment,"Notes")>
			<cfinvokeargument name="Notes" value="#arguments.sPayment.Notes#">
		</cfif>
	</cfinvoke>
	
	<cfreturn arguments.OrderID>
</cffunction>

<cffunction name="processPayment" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I process the payment for an order.">
	<cfargument name="OrderID" type="numeric" required="yes" hint="The OrderID for the order being payed.">
	<cfargument name="cc" type="string" required="yes" hint="The credit card number used to pay for the order.">
	<cfargument name="ccv" type="string" required="yes" hint="The verification number from the credit card.">
	<cfargument name="year" type="numeric" required="yes" hint="The year the card expires.">
	<cfargument name="month" type="numeric" required="yes" hint="The month that the credit card expires.">
	<cfargument name="CreditCardID" type="numeric" required="no" hint="The CreditCardID for the type of card being used (Amex, MasterCard, Visa, etcetera).">
	
	<cfset var qOrder = variables.Orders.getOrder(arguments.OrderID)>
	<cfset var qCustomer = 0>
	<cfset var qBillingAddress = getBillingAddress(arguments.OrderID)>
	<cfset var oGateway = variables.cfpayment.getGateway()>
	<cfset var oMoney = 0>
	<cfset var oAccount = 0>
	<cfset var oResponse = 0>
	<cfset var aErrors = 0>
	<cfset var sOptions = StructNew()>
	<cfset var money = qOrder.OrderTotal>
	
	<!--- One dollar for Authorize.net test as it uses amount to determine success/failure --->
	<cfif oGateway.getGatewayName() EQ "Authorize.net" AND oGateway.getTestMode()>
		<cfset money = 1>
	</cfif>
	
	<!--- create a money object to hold the amount in cents --->
	<cfset oMoney = cfpayment.createMoney(money * 100, "USD")>
	
	<cfif NOT qBillingAddress.RecordCount>
		<cfset throwError("Order must having a billing address.")>
	</cfif>
	
	<cfscript>
	//create an account to charge
	oAccount = cfpayment.createCreditCard();
	if ( oGateway.getGatewayName() EQ "Bogus Gateway" ) {
		oAccount.setAccount("1");
	} else {
		oAccount.setAccount(arguments.cc);
	}
	oAccount.setVerificationValue(arguments.ccv);
	oAccount.setMonth(arguments.month);
	oAccount.setYear(arguments.year);
	oAccount.setFirstName(qBillingAddress.FirstName);
	oAccount.setLastName(qBillingAddress.LastName);
	oAccount.setAddress(qBillingAddress.Address1);
	if ( Len(Trim(qBillingAddress.Address2)) ) {
		oAccount.setAddress2(qBillingAddress.Address2);
	}
	oAccount.setCity(qBillingAddress.City);
	oAccount.setPostalCode(qBillingAddress.PostalCode);
	
	//authorize the card
	//oResponse = oGateway.authorize(money = oMoney, account = oAccount, options=StructNew() );
	//oResponse = oGateway.purchase(money = oMoney, account = oAccount, options=StructNew() );
	
	//flag the authorization for settlement into your bank account
	//oResponse = oGateway.capture(money = oMoney, authorization=oResponse.getAuthorization(), options=StructNew(), transactionid = oResponse.getTransactionID());
	
	//changed my mind, let's void it
	//oResponse = oGateway.void(transactionid = response.getTransactionID());
	</cfscript>
	
	<cfset aErrors = oAccount.validate()>
	
	<cfif ArrayLen(aErrors)>
		<cfset throwError(message=aErrors[1].Message,ExtendedInfo=aErrors[1].Field)>
	</cfif>
	
	<cfif Len(qOrder.PaymentTransactionNumber)>
		<cfset sOptions["x_trans_ID"] = qOrders.PaymentTransactionNumber>
	</cfif>
	
	<cfset oResponse = oGateway.purchase(money = oMoney, account = oAccount, options=sOptions )>
	
	<cfif NOT oResponse.getSuccess()>
		<!--- <cfdump var="#oResponse#"><br />
		<cfdump var="#oResponse.getResult()#"><br />
		<cfdump var="#oResponse.getParsedResult()#"><br />
		<cfdump var="#oResponse.getSuccess()#"><br />
		<cfdump var="#oResponse.hasError()#"><br />
		<cfdump var="#oResponse.getStatus()#"><br />
		<cfdump var="#oResponse.getMessage()#"><br />
		<cfabort> --->
		<cfset throwError(message=oResponse.getMessage(),extendedinfo=oResponse.getResult())>
	</cfif>
	
	<cfinvoke method="recordAction">
		<cfinvokeargument name="OrderID" value="#arguments.OrderID#">
		<cfinvokeargument name="Action" value="Charge">
		<cfif StructKeyExists(arguments,"Notes")>
			<cfinvokeargument name="Notes" value="#arguments.Notes#">
		</cfif>
		<cfinvokeargument name="PaymentTransactionNumber" value="#oResponse.getTransactionID()#">
		<cfinvokeargument name="CardLastFour" value="#Right(arguments.cc,4)#">
		<cfinvokeargument name="CardLength" value="#Len(arguments.cc)#">
		<cfif StructKeyExists(arguments,"CreditCardID")>
			<cfinvokeargument name="CreditCardID" value="#arguments.CreditCardID#">
		</cfif>
	</cfinvoke>
	
	<cfinvoke method="recordAction">
		<cfinvokeargument name="OrderID" value="#arguments.OrderID#">
		<cfinvokeargument name="Action" value="Complete">
	</cfinvoke>
	
</cffunction>

<cffunction name="removeItem" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I remove an item from the user's cart/order.">
	<cfargument name="OrderID" type="numeric" required="yes" hint="The OrderID for the order being changed.">
	<cfargument name="ProductIdentifier" type="string" required="yes" hint="The ProductIdentifier of the product being removed from the cart.">
	
	<cfset var OrderItemID = variables.OrderItems.getOrderItemID(OrderID,arguments.ProductIdentifier)>
	
	<cfset variables.OrderItems.removeOrderItem(OrderItemID)>
	
	<cfset updateOrderTotal(arguments.OrderID)>
	
</cffunction>

<cffunction name="setBillingAddress" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I set the billing address for the order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="FirstName" type="string" required="no">
	<cfargument name="LastName" type="string" required="no">
	<cfargument name="Address1" type="string" required="no">
	<cfargument name="Address2" type="string" required="no">
	<cfargument name="City" type="string" required="no">
	<cfargument name="StateCode" type="string" required="no">
	<cfargument name="PostalCode" type="string" required="no">
	<cfargument name="Comments" type="string" required="no">
	<cfargument name="StateProvinceID" type="numeric" required="no">
	<cfargument name="CustomerID" type="numeric" required="no">
	<cfargument name="AddressID" type="numeric" required="no">
	
	<cfset var sOrder = StructNew()>
	
	<cfset arguments.AddressID = variables.Addresses.saveAddress(argumentCollection=arguments)>
	
	<cfset sOrder["OrderID"] = arguments.OrderID>
	<cfset sOrder["BillingAddressID"] = arguments.AddressID>
	<cfset sOrder["total"] = true>
	<cfset sOrder["BillingAddress"] = variables.Addresses.getAddressHTML(arguments.AddressID)>
	<cfif StructKeyExists(arguments,"CustomerID")>
		<cfset sOrder["CustomerID"] = arguments.CustomerID>
	</cfif>
	
	<cfset variables.Orders.saveOrder(argumentCollection=sOrder)>
	
</cffunction>

<cffunction name="setBuyer" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I set the buyer (billing address and customer record) for the order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Address1" type="string" required="no">
	<cfargument name="Address2" type="string" required="no">
	<cfargument name="City" type="string" required="no">
	<cfargument name="StateCode" type="string" required="no">
	<cfargument name="PostalCode" type="string" required="no">
	<cfargument name="Comments" type="string" required="no">
	<cfargument name="StateProvinceID" type="numeric" required="no">
	<cfargument name="Phone" type="string" required="no">
	
	<cfset arguments.CustomerID = setCustomer(argumentCollection=arguments)>
	
	<cfreturn setBillingAddress(argumentCollection=arguments)>
</cffunction>

<cffunction name="setCustomer" access="public" returntype="numeric" output="false" doc:Group="Order Processing" hint="I set the customer record for the order.">
	<cfargument name="FirstName" type="string" required="no">
	<cfargument name="LastName" type="string" required="no">
	<cfargument name="Email" type="string" required="no">
	<cfargument name="Phone" type="string" required="no">
	
	<cfreturn variables.Customers.saveCustomer(argumentCollection=arguments)>
</cffunction>

<cffunction name="setRecipient" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I set the shipping address for the order (setRecipient,setShippee,setShippingAddress are all different method names for the same action).">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Address1" type="string" required="no">
	<cfargument name="Address2" type="string" required="no">
	<cfargument name="City" type="string" required="no">
	<cfargument name="StateCode" type="string" required="no">
	<cfargument name="PostalCode" type="string" required="no">
	<cfargument name="Comments" type="string" required="no">
	<cfargument name="StateProvinceID" type="numeric" required="no">
	
	<cfset setShippingAddress(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="setShippee" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I set the shipping address for the order (setRecipient,setShippee,setShippingAddress are all different method names for the same action).">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Address1" type="string" required="no">
	<cfargument name="Address2" type="string" required="no">
	<cfargument name="City" type="string" required="no">
	<cfargument name="StateCode" type="string" required="no">
	<cfargument name="PostalCode" type="string" required="no">
	<cfargument name="Comments" type="string" required="no">
	<cfargument name="StateProvinceID" type="numeric" required="no">
	
	<cfset setShippingAddress(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="setShippingAddress" access="public" returntype="void" output="false" doc:Group="Order Processing" hint="I set the shipping address for the order (setRecipient,setShippee,setShippingAddress are all different method names for the same action).">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Address1" type="string" required="no">
	<cfargument name="Address2" type="string" required="no">
	<cfargument name="City" type="string" required="no">
	<cfargument name="StateCode" type="string" required="no">
	<cfargument name="PostalCode" type="string" required="no">
	<cfargument name="Comments" type="string" required="no">
	<cfargument name="StateProvinceID" type="numeric" required="no">
	<cfargument name="CustomerID" type="numeric" required="no">
	<cfargument name="AddressID" type="numeric" required="no">
	
	<cfset var sOrder = StructNew()>
	
	<cfset arguments.AddressID = variables.Addresses.saveAddress(argumentCollection=arguments)>
	
	<cfset sOrder["OrderID"] = arguments.OrderID>
	<cfset sOrder["total"] = false>
	<cfset sOrder["ShippingAddressID"] = arguments.AddressID>
	<cfset sOrder["ShippingAddress"] = variables.Addresses.getAddressHTML(arguments.AddressID)>
	
	<cfset variables.Orders.saveOrder(argumentCollection=sOrder)>
	
</cffunction>

<cffunction name="setDiscount" access="public" returntype="any" output="false" doc:Group="Order Processing" hint="I attempt to apply a discount to the order.">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="DiscountCode" type="string" required="yes">
	
	<cfset var qOrder = variables.Orders.getOrder(OrderID=arguments.OrderID,fieldlist="OrderID,Subtotal")>
	<cfset var sOrder = StructNew()>
	<cfset var sDiscountInfo = variables.Discounts.getDiscountInfo(arguments.DiscountCode,qOrder.Subtotal)>
	
	<cfset sOrder["OrderID"] = arguments.OrderID>
	<cfset sOrder["DiscountID"] = sDiscountInfo["DiscountID"]>
	<cfset sOrder["PromoCode"] = sDiscountInfo["DiscountCode"]>
	<cfset sOrder["DiscountAmount"] = sDiscountInfo["Amount"]>
	
	<cfset variables.Orders.saveOrder(argumentcollection=sOrder)>
	
</cffunction>

<cffunction name="shipOrder" access="public" returntype="any" output="false" doc:Group="Administration" hint="I mark the order as shipped and take any steps tied to that action.">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="ShipperTrackingNumber" type="string" required="no">
	<cfargument name="Notes" type="string" required="no">
	
	<cfset var sAction = StructCopy(arguments)>
	
	<cfset variables.Orders.saveorder(argumentCollection=arguments)>
	
	<cfset sAction["Action"] = "Ship">
	
	<cfset recordAction(argumentCollection=sAction)>
	
</cffunction>

<cffunction name="updateItem" access="public" returntype="numeric" output="false" doc:Group="Administration" hint="I update/change an item in the order and return the OrderItemID for the item.">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="ProductName" type="string" required="yes">
	<cfargument name="ProductInfo" type="string" required="yes">
	<cfargument name="Price" type="numeric" required="yes">
	<cfargument name="Quantity" type="numeric" required="yes">
	
	<cfset var sOrderItem = StructCopy(arguments)>
	
	<cfset sOrderItem["OrderItemID"] = variables.OrderItems.getOrderItemID(arguments.ProductIdentifier)>
	
	<cfset sOrderItem["OrderItemID"] = variables.OrderItems.saveOrderItem(argumentCollection=sOrderItem)>
	
	<cfset updateOrderTotal(arguments.OrderID)>
	
	<cfreturn sOrderItem["OrderItemID"]>
</cffunction>

<!---<cffunction name="updateOrder" access="public" returntype="any" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Items" type="array" required="no">
	<cfargument name="BillingInfo" type="struct" required="no">
	<cfargument name="ShippingInfo" type="struct" required="no">
</cffunction>--->

<cffunction name="updateItems" access="public" returntype="any" output="false" doc:Group="Administration" hint="I update a product across any active (non-completed) carts/orders.">
	<cfargument name="ProductIdentifier" type="string" required="yes" hint="The unique identifier for the product being changed. Any items using this ProductIdentifier for uncompleted orders will be affected.">
	<cfargument name="Price" type="numeric" required="no">
	<cfargument name="ProductName" type="string" required="no">
	<cfargument name="ProductInfo" type="string" required="no">
	<cfargument name="LinkAdmin" type="string" required="no">
	<cfargument name="LinkPublic" type="string" required="no">
	
	<cfset variables.OrderItems.updateItems(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="updateItemPrices" access="public" returntype="any" output="false" doc:Group="Administration" hint="I update only the price for a product across any active (non-completed) carts/orders.">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="Price" type="numeric" required="yes">
	
	<cfset variables.OrderItems.updateItemPrices(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="createOrder" access="public" returntype="numeric" output="false" doc:Group="Order Processing" hint="I create a new cart/order and return the OrderID.">
	<cfargument name="OrderTotal" type="numeric" default="0">
	
	<cfreturn variables.Orders.addOrder(argumentCollection=arguments)>
</cffunction>

<cffunction name="recordAction" access="package" returntype="numeric" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Action" type="string" required="yes">
	<cfargument name="Notes" type="string" required="no">
	
	<cfreturn variables.OrderActions.addOrderAction(argumentCollection=arguments)>
</cffunction>

<cffunction name="updateOrderTotal" access="private" returntype="any" output="false" hint="">
	<cfargument name="OrderID" type="any" required="yes">
	
	<cfset variables.Orders.updateOrderTotal(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="CentsCeiling" access="public" returntype="numeric" output="false" doc:Group="Utility" hint="I increase a numeric up to the nearest cent.">
	<cfargument name="amount" type="numeric" required="yes">
	
	<cfreturn ( Ceiling(arguments.amount * 100) / 100 )>
</cffunction>

<cffunction name="CentsInt" access="public" returntype="numeric" output="false" doc:Group="Utility" hint="I decrease a numeric down to the nearest cent.">
	<cfargument name="amount" type="numeric" required="yes">
	
	<cfreturn ( Int(arguments.amount * 100) / 100 )>
</cffunction>

<cffunction name="CentsRound" access="public" returntype="numeric" output="false" doc:Group="Utility" hint="I round a numeric to the nearest cent.">
	<cfargument name="amount" type="numeric" required="yes">
	
	<cfreturn ( Round(arguments.amount * 100) / 100 )>
</cffunction>

<cffunction name="MaskedCardNumber" access="public" returntype="any" output="false" doc:Group="Utility" hint="I take the last four digits of a credit card number and the desired length and return a string of the appropriate length with the digits preceding the last four using Xs.">
	<cfargument name="CardLastFour" type="string" required="yes">
	<cfargument name="CardLength" type="numeric" default="16">
	
	<cfset var result = "">
	<cfset var ii = 0>
	
	<cfif arguments.CardLength LTE 4>
		<cfset arguments.CardLength = 16>
	</cfif>
	
	<cfloop index="ii" from="1" to="#CardLength-4#" step="1">
		<cfset result = "#result#X">
	</cfloop>
	<cfif isNumeric(CardLastFour)>
		<cfset result = "#result##NumberFormat(CardLastFour,'0000')#">
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="xml" access="public" returntype="void" output="yes">
<tables prefix="#variables.prefix#">
	<table entity="Action" Specials="Sorter">
		<field name="Status" Label="Status" type="text" Length="120" />
		<field name="HasStatus">
			<relation
				type="has"
				field="Status"
			/>
		</field>
		<data permanentRows="true" checkFields="ActionName" onexists="update">
			<row ActionName="Start" Status="Pending" />
			<row ActionName="Update" />
			<row ActionName="Complete" Status="Placed" />
			<row ActionName="Charge" Status="Paid" />
			<row ActionName="Ship" Status="Shipped" />
			<row ActionName="Cancel" Status="Cancelled" />
			<row ActionName="Return" Status="Returned" />
		</data>
	</table>
	<table entity="Address" labelField="Addressee">
		<field fentity="Order" sebcolumn="false" />
		<field fentity="Customer" />
		<field fentity="State / Province" required="true" />
		<field name="FirstName" label="First Name" type="text" Length="60" required="true" sebcolumn="false" />
		<field name="LastName" Label="Last Name" type="text" Length="60" required="true" sebcolumn="false" />
		<field name="Addressee" type="relation">
			<relation
				type="concat"
				fields="FirstName,LastName"
				delimiter=" "
			/>
		</field>
		<field name="Address1" label="Address" type="text" Length="180" required="true" sebcolumn="false" />
		<field name="Address2" label="Address 2" type="text" Length="180" sebcolumn="false" />
		<field name="City" Label="City" type="text" Length="120" required="true" sebcolumn="false" />
		<field name="PostalCode" Label="Postal Code" type="text" Length="60" size="10" required="true" sebcolumn="false" />
		<field name="DateCreated" Label="Date Created" type="CreationDate" sebcolumn="false" />
		<field name="DateUpdated" Label="Date Updated" type="LastUpdatedDate" sebcolumn="false" />
		<field name="Comments" type="memo" sebcolumn="false" />
		<field name="StateCode" label="State">
			<relation
				type="label"
				entity="State / Province"
				field="Code"
				join-field="StateProvinceID"
			/>
		</field>
	</table>
	<table entity="Country">
		<data>
			<row CountryName="United States" />
		</data>
	</table>
	<table entity="Credit Card" Specials="Sorter">
		<data>
			<row CreditCardName="Visa" />
			<row CreditCardName="MasterCard" />
			<row CreditCardName="American Express" />
			<row CreditCardName="Discover" />
		</data>
	</table>
	<table entity="Customer" Specials="CreationDate,LastUpdatedDate" onExists="update">
		<field name="FirstName" Label="First Name" type="text" Length="60" />
		<field name="LastName" Label="Last Name" type="text" Length="60" />
		<field name="CustomerName" Label="Customer" type="relation">
			<relation
				type="concat"
				fields="FirstName,LastName"
				delimiter=" "
			/>
		</field>
		<field name="Email" Label="Email" type="text" Length="180" />
		<field name="Phone" Label="Phone" type="text" Length="120" />
		<field name="NumOrders" label="Orders">
			<relation
				type="count"
				entity="Order"
				field="OrderID"
				join-field="CustomerID"
			>
				<filter field="isPaid" operator="=" value="1" />
			</relation>
		</field>
		<field name="HasOrders" label="Has Orders?">
			<relation
				type="has"
				field="NumOrders"
			/>
		</field>
	</table>
	<table entity="Discount" Specials="CreationDate,LastUpdatedDate">
		<field name="PromoCode" Label="Promotional Code" type="text" Length="80" />
		<field name="DateBegin" Label="Begin Date" type="date" />
		<field name="DateEnd" Label="End Date" type="date" />
		<field name="DiscountPercent" Label="Discount Percent" type="integer" input_suffix="%" />
		<field name="DiscountAmount" Label="Discount Amount" type="money" input_prefix="$" />
		<field name="Description" type="text" Length="255" />
		<field name="MinPurchaseTotal" Label="Minimum Purchase Total" type="money" />
		<field name="MaxUses" Label="Maximum Uses" type="integer" />
		<field name="DateDeleted" type="DeletionDate" />
		<field name="NumOrders">
			<relation
				type="count"
				entity="Order"
				field="OrderID"
				join-field="DiscountID"
			>
				<filter field="isPaid" operator="=" value="1" />
			</relation>
		</field>
	</table>
	<table entity="Order Action" labelField="DateTimeTaken">
		<field fentity="Order" />
		<field fentity="Action" />
		<field fentity="Credit Card" />
		<field name="DateTimeTaken" Label="When Done" type="CreationDate" />
		<field name="Notes" type="memo" rows="3" />
		<field name="ShipperTrackingNumber" Label="Shipper Tracking Number" type="text" Length="180" />
		<field name="PaymentTransactionNumber" Label="Payment Transaction Number" type="text" Length="180" />
		<field name="CardLastFour" Label="Card Last Four" type="text" Length="4" />
		<field name="CardLength" Label="Card Length" type="integer" />
		<field name="Status">
			<relation
				type="label"
				entity="Action"
				field="Status"
				join-field="ActionID"
			/>
		</field>
		<field name="hasStatus">
			<relation
				type="has"
				field="Status"
			/>
		</field>
		<field name="LastMessageSent" label="Message Sent">
			<relation
				type="max"
				entity="Order Action Message"
				field="DateTimeSent"
				join-field="OrderActionID"
			/>
		</field>
		<filter name="Statuses" field="Status" operator="IN" />
		<filter name="BeginDate" field="DatePlaced" operator="GTE" />
		<filter name="EndDate" field="DatePlaced" operator="LTE" />
	</table>
	<table entity="Order Action Message" labelField="DateTimeSent">
		<field fentity="Order Action" />
		<field name="DateTimeSent" Label="When Sent" type="CreationDate" />
	</table>
	<table entity="Order Item" labelField="ProductName" Specials="CreationDate,LastUpdatedDate,Sorter">
		<field fentity="Order" />
		<field name="ProductIdentifier" Label="Product Identifier" type="text" Length="120" />
		<field name="ProductName" Label="Product Name" type="text" Length="120" />
		<field name="ProductInfo" Label="Product Info" type="memo" />
		<field name="Price" type="money" />
		<field name="Quantity" type="integer" />
		<field name="LinkAdmin" Label="Admin Link URL" type="text" Length="240" />
		<field name="LinkPublic" Label="Public Link URL" type="text" Length="240" />
		<field name="isShippable" Label="Shippable?" type="boolean" default="true" />
		<field name="CustomerID">
			<relation
				type="label"
				entity="Order"
				field="CustomerID"
			/>
		</field>
	</table>
	<table entity="Order" labelField="DatePlaced">
		<field fentity="Customer" />
		<field fentity="Discount" />
		<field fentity="Shipper" />
		<field name="BillingAddressID" Label="Address" type="fk:integer" listshowfield="Address" />
		<field name="ShippingAddressID" Label="Address" type="fk:integer" listshowfield="Address" />
		<field fentity="Credit Card" />
		<field name="ship2billing" Label="Ship to Billing Address?" type="boolean" />
		<field name="DiscountCode" Label="Discount Code" type="relation">
			<relation
				type="label"
				entity="Discount"
				field="PromoCode"
				join-field="DiscountID"
			/>
		</field>
		<field name="Subtotal" type="money" />
		<field name="ShippingCost" Label="Shipping Cost" type="money" />
		<field name="Tax" type="money" />
		<field name="DiscountAmount" type="money" />
		<field name="PromoCode" Label="Promotional Code" type="text" Length="80" />
		<field name="OrderTotal" Label="Order Total" type="money" />
		<field name="ShippingAddress" Label="Shipping Address" type="memo" />
		<field name="BillingAddress" Label="Billing Address" type="memo" />
		<field name="ShipperTrackingNumber" Label="Shipper Tracking Number" type="text" Length="200" />
		<field name="PaymentTransactionNumber" Label="Payment Transaction Number" type="text" Length="180" />
		<field name="CardLastFour" Label="Card Last Four" type="text" Length="4" />
		<field name="CardLength" Label="Card Length" type="integer" />
		<field name="DatePlaced" Label="Date Placed" type="CreationDate" />
		<field name="DateUpdated" Label="Date Updated" type="LastUpdatedDate" />
		<field name="Email" Label="Email" type="relation">
			<relation
				type="label"
				entity="Customer"
				field="Email"
				join-field="CustomerID"
			/>
		</field>
		<field name="NumShippableItems">
			<relation
				type="count"
				entity="Order Item"
				field="OrderItemID"
				join-field="OrderID"
			>
				<filter field="isShippable" value="true" />
			</relation>
		</field>
		<field name="isShippingOrder">
			<relation
				type="has"
				field="NumShippableItems"
			/>
		</field>
		<field name="StatusID" Label="Status" type="relation">
			<relation
				type="max"
				entity="Order Action"
				field="ActionID"
			>
				<filter field="hasStatus" value="true" />
			</relation>
		</field>
		<field name="Status" Label="Status" type="relation">
			<relation
				type="label"
				entity="Order Action"
				field="Status"
				join-field-local="StatusID"
				join-field-remote="ActionID"
			/>
		</field>
		<field name="Statuses" Label="Statuses" type="relation">
			<relation
				type="list"
				entity="Order Action"
				field="Status"
				join-field="OrderID"
			/>
		</field>
		<field name="NumChargeActions">
			<relation
				type="count"
				entity="Order Action"
				field="OrderActionID"
				join-field="OrderID"
			>
				<filter field="Status" operator="=" value="Paid" />
			</relation>
		</field>
		<field name="isPaid">
			<relation
				type="has"
				field="NumChargeActions"
			/>
		</field>
		<field name="NumCompletionActions">
			<relation
				type="count"
				entity="Order Action"
				field="OrderActionID"
				join-field="OrderID"
			>
				<filter field="Status" operator="=" value="Placed" />
			</relation>
		</field>
		<field name="isCompleted">
			<relation
				type="has"
				field="NumChargeActions"
			/>
		</field>
		<field name="NumShipActions">
			<relation
				type="count"
				entity="Order Action"
				field="OrderActionID"
				join-field="OrderID"
			>
				<filter field="Status" operator="=" value="Shipped" />
			</relation>
		</field>
		<field name="isShipped">
			<relation
				type="has"
				field="NumShipActions"
			/>
		</field>
	</table>
	<table entity="Shipper" />
	<table entity="State / Province">
		<field fentity="Country" />
		<field name="Code" Label="Code" type="text" Length="20" />
		<field name="TaxPercent" Label="Tax Percent" type="decimal" default="0" input_suffix="%" precision="5" scale="3" />
		<data>
			<row Country="United States" Code="AL" StateProvinceName="Alabama" />
			<row Country="United States" Code="AK" StateProvinceName="Alaska" />
			<row Country="United States" Code="AZ" StateProvinceName="Arizona" />
			<row Country="United States" Code="AR" StateProvinceName="Arkansas" />
			<row Country="United States" Code="CA" StateProvinceName="California" />
			<row Country="United States" Code="CO" StateProvinceName="Colorado" />
			<row Country="United States" Code="CT" StateProvinceName="Connecticut" />
			<row Country="United States" Code="DE" StateProvinceName="Delaware" />
			<row Country="United States" Code="FL" StateProvinceName="Florida" />
			<row Country="United States" Code="GA" StateProvinceName="Georgia" />
			<row Country="United States" Code="HI" StateProvinceName="Hawaii" />
			<row Country="United States" Code="ID" StateProvinceName="Idaho" />
			<row Country="United States" Code="IL" StateProvinceName="Illinois" />
			<row Country="United States" Code="IN" StateProvinceName="Indiana" />
			<row Country="United States" Code="IA" StateProvinceName="Iowa" />
			<row Country="United States" Code="KS" StateProvinceName="Kansas" />
			<row Country="United States" Code="KY" StateProvinceName="Kentucky" />
			<row Country="United States" Code="LA" StateProvinceName="Louisiana" />
			<row Country="United States" Code="ME" StateProvinceName="Maine" />
			<row Country="United States" Code="MD" StateProvinceName="Maryland" />
			<row Country="United States" Code="MA" StateProvinceName="Massachusetts" />
			<row Country="United States" Code="MI" StateProvinceName="Michigan" />
			<row Country="United States" Code="MN" StateProvinceName="Minnesota" />
			<row Country="United States" Code="MS" StateProvinceName="Mississippi" />
			<row Country="United States" Code="MO" StateProvinceName="Missouri" />
			<row Country="United States" Code="MT" StateProvinceName="Montana" />
			<row Country="United States" Code="NE" StateProvinceName="Nebraska" />
			<row Country="United States" Code="NV" StateProvinceName="Nevada" />
			<row Country="United States" Code="NH" StateProvinceName="New Hampshire" />
			<row Country="United States" Code="NJ" StateProvinceName="New Jersey" />
			<row Country="United States" Code="NM" StateProvinceName="New Mexico" />
			<row Country="United States" Code="NY" StateProvinceName="New York" />
			<row Country="United States" Code="NC" StateProvinceName="North Carolina" />
			<row Country="United States" Code="ND" StateProvinceName="North Dakota" />
			<row Country="United States" Code="OH" StateProvinceName="Ohio" />
			<row Country="United States" Code="OK" StateProvinceName="Oklahoma" />
			<row Country="United States" Code="OR" StateProvinceName="Oregon" />
			<row Country="United States" Code="PA" StateProvinceName="Pennsylvania" />
			<row Country="United States" Code="RI" StateProvinceName="Rhode Island" />
			<row Country="United States" Code="SC" StateProvinceName="South Carolina" />
			<row Country="United States" Code="SD" StateProvinceName="South Dakota" />
			<row Country="United States" Code="TN" StateProvinceName="Tennessee" />
			<row Country="United States" Code="TX" StateProvinceName="Texas" />
			<row Country="United States" Code="UT" StateProvinceName="Utah" />
			<row Country="United States" Code="VT" StateProvinceName="Vermont" />
			<row Country="United States" Code="VA" StateProvinceName="Virginia" />
			<row Country="United States" Code="WA" StateProvinceName="Washington" />
			<row Country="United States" Code="WV" StateProvinceName="West Virginia" />
			<row Country="United States" Code="WI" StateProvinceName="Wisconsin" />
			<row Country="United States" Code="WY" StateProvinceName="Wyoming" />
		</data>
	</table>
	<table prefix="prod" entity="Product" folder="cart,products" Specials="CreationDate,LastUpdatedDate">
		<field name="Price" type="money" required="true" />
		<field name="ProductDescription" Label="Description" type="memo" useInMultiRecordsets="false" />
		<field name="OrderNum" type="Sorter" />
	</table>
	<table entity="Product View" name="prodViews" labelField="ViewDateTime">
		<field fentity="Product" />
		<field name="ViewDateTime" Label="When Viewed" type="CreationDate" />
		<field name="IP" Label="IP" type="text" Length="20" />
		<field name="UserAgent" Label="User Agent (Browser)" type="text" Length="255" />
	</table>
</tables>
</cffunction>

<!---<cffunction name="loadNotices" access="private" returntype="any" output="false" hint="">
	
	<cfset var sNotice = StructNew()>
	
</cffunction>--->

<cffunction name="loadScheduledTask" access="private" returntype="any" output="false" hint="">
	
	<cfif StructKeyExists(variables,"Scheduler")>
		<cfinvoke component="#variables.Scheduler#" method="setTask">
			<cfinvokeargument name="Name" value="StarterCart">
			<cfinvokeargument name="ComponentPath" value="admin.cart.sys.StarterCart">
			<cfinvokeargument name="Component" value="#This#">
			<cfinvokeargument name="MethodName" value="runScheduledTask">
			<cfinvokeargument name="interval" value="hourly">
		</cfinvoke>
	</cfif>
	
</cffunction>

<cffunction name="runScheduledTask" access="public" returntype="any" output="false" doc:Group="Utility" hint="I am called every hour and used to run any custom code that needs to be run on a regular basis.">
	
	
</cffunction>

<!---<cffunction name="sendNotice" access="public" returntype="void" output="false" hint="">
	<cfargument name="Action" type="string" required="yes">
	
	<cfif StructKeyExists(variables,"NoticeMgr")>
	
	</cfif>
	
</cffunction>--->

<cffunction name="loadComponent" access="private" returntype="any" output="no" hint="I load a component into memory in this component.">
	<cfargument name="name" type="string" required="yes">
	
	<cfset var ext = getCustomExtension()>
	<cfset var extpath = "">
	
	<cfif NOT StructKeyExists(arguments,"path")>
		<cfset arguments.path = "#variables.me.path#.#arguments.name#">
	</cfif>
	
	<cfset extpath = "#getDirectoryFromPath(getCurrentTemplatePath())##arguments.name#_#ext#.cfc">
	
	<cfif Len(ext) AND FileExists(extpath)>
		<cfset arguments.path = "#arguments.path#_#ext#">
	</cfif>
	
	<cfset arguments["Manager"] = variables.Manager>
	<cfset arguments["Parent"] = This>
	<cfset arguments[variables.me.name] = This>
	
	<cfinvoke component="#arguments.path#" method="init" returnvariable="this.#name#" argumentCollection="#arguments#"></cfinvoke>
	
	<cfset variables[arguments.name] = This[arguments.name]>
	
</cffunction>

<cffunction name="sendEmailAlert" access="package" returntype="void" output="false" hint="">
	<cfargument name="Subject" type="string" required="yes">
	<cfargument name="html" type="string" required="yes">
	
	<cfset var oMailer = 0>
	
	<cfif StructKeyExists(variables,"NoticeMgr")>
		<cfset oMailer = variables.NoticeMgr.getMailer()>
	</cfif>
	
	<cfif StructKeyExists(variables,"NoticeMgr") AND StructKeyExists(variables,"ErrorEmail") AND Len(Trim(variables.ErrorEmail))>
		<cfinvoke component="#oMailer#" method="send">
			<cfinvokeargument name="To" value="#variables.ErrorEmail#">
			<cfinvokeargument name="Subject" value="#arguments.Subject#">
			<cfinvokeargument name="html" value="#arguments.html#">
		</cfinvoke>
	<cfelse>
		<cfmail to="steve@bryantwebconsulting.com" from="system@tulsahost.com" server="mail.tulsahost.com" type="html" subject="Cart Error">#arguments.html#</cfmail>
	</cfif>
	
</cffunction>

<cffunction name="throwError" access="public" returntype="void" output="false" hint="">
	<cfargument name="message" type="string" required="yes">
	<cfargument name="errorcode" type="string" default="">
	<cfargument name="detail" type="string" default="">
	<cfargument name="extendedinfo" type="string" default="">
	
	<cfset var html = "">
	
	<cfsavecontent variable="html"><cfoutput><cfdump var="#arguments#"></cfoutput></cfsavecontent>
	<cfset sendEmailAlert("Cart Error",html)>
	
	<cfthrow
		type="StarterCart"
		message="#arguments.message#"
		errorcode="#arguments.errorcode#"
		detail="#arguments.detail#"
		extendedinfo="#arguments.extendedinfo#"
	>
	
</cffunction>

</cfcomponent>