<cfimport prefix="cart" taglib="../cart/tags">
<cf_PageController>

<cf_layout>
	<script type="text/javascript" src="/checkout/cart.js"></script>
	<script type="text/javascript" src="order-edit.js"></script>
<cf_layout showTitle="true">

<cf_sebForm sebformjs="true" format="semantic" CFC_Component="#Application.StarterCart.Orders#" sendback="true">
	<cf_sebGroup label="Order Information">
		<cfoutput query="qOrder">
		<cf_sebField type="custom1">
			Placed By: <a href="customer-edit.cfm?id=#CustomerID#">#Customer#</a><br />
			Date Placed: #DateFormat(DatePlaced,"mmmm dd, yyyy")#<br />
			<cfif Len(PaymentTransactionNumber)>
			Transaction Number: #PaymentTransactionNumber#<br />
			</cfif>
			<cfif Len(MaskedCardNumber)>
			Card: #MaskedCardNumber#<br />
			</cfif>
			<br />
		</cf_sebField>
		</cfoutput>
		<div id="cart-details">
			<cart:items isAdmin="true" isReview="true" />
		</div>
	</cf_sebGroup>
	<cart:addresses isReview="true" />
</cf_sebForm>

<cfif Action EQ "Edit">
	<cfif qPossibleActions.RecordCount>
		<p>&nbsp;</p>
		<h3>Change Status:</h3>
		<cf_sebForm CFC_Component="#Application.StarterCart.OrderActions#" CFC_Method="addOrderAction">
			<cf_sebField name="OrderID" type="hidden" setValue="#URL.id#">
			<cf_sebField name="Action" label="Status" type="select" subquery="qPossibleActions" subvalues="Action" onChange="changeAction();">
			<cf_sebField name="ShipperTrackingNumber" label="Tracking ##">
			<cf_sebField name="Notes">
			<cf_sebField type="Submit" label="Submit">
		</cf_sebForm>
	</cfif>
	
	<cf_layout include="order_action-list.cfm" style="margin-top:20px;">
</cfif>

<cf_layout>