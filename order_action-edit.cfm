<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cfoutput query="qOrderAction">
	<p><a href="order-edit.cfm?id=#OrderID#">Return to Order</a></p>
</cfoutput>

<cf_sebForm query="qOrderAction" CFC_Component="#Application.StarterCart.OrderActions#">
	<cf_sebField name="DateTimeTaken" type="plaintext">
	<cf_sebField name="Action" type="plaintext">
	<cfif Len(qOrderAction.Notes)>
		<cf_sebField name="Notes" type="plaintext">
	</cfif>
	<cfif Len(qOrderAction.ShipperTrackingNumber)>
		<cf_sebField name="ShipperTrackingNumber" type="plaintext">
	</cfif>
	<cfif Len(qOrderAction.CreditCard)>
		<cf_sebField name="CreditCard" label="Credit Card" type="plaintext">
	</cfif>
	<cfif Len(qOrderAction.MaskedCardNumber)>
		<cf_sebField name="MaskedCardNumber" label="Card Number" type="plaintext">
	</cfif>
	<cfif Len(qOrderAction.PaymentTransactionNumber)>
		<cf_sebField name="PaymentTransactionNumber" type="plaintext">
	</cfif>
	<cfif hasActionNotice AND isDate(qOrderAction.LastMessageSent)>
		<cf_sebField name="LastMessageSent" type="plaintext">
	</cfif>
</cf_sebForm>

<cfif hasActionNotice>
	<cf_sebForm CFC_Component="#Application.StarterCart.OrderActions#" CFC_Method="sendOrderActionNotice">
		<cfif qOrderActionMessages.RecordCount>
			<cf_sebField type="submit" label="Resend Message">
		<cfelse>
			<cf_sebField type="submit" label="Send Message">
		</cfif>
	</cf_sebForm>
	<cfif qOrderActionMessages.RecordCount GT 1>
		<cf_sebTable query="qOrderActionMessages" pkfield="OrderActionMessageID" label="Messages" labelSuffix="" isAddable="false" isEditable="false">
			<cf_sebColumn dbfield="DateTimeSent" type="datetime" label="When" defaultSort="DESC">
		</cf_sebTable>
	</cfif>
</cfif>

<cf_layout>