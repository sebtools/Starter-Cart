<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cf_PageController>

<cfif isReview>
	<cf_sebGroup label="Addresses">
		<cf_sebField name="blah" type="custom1" label=" "><cfoutput>
			<table width="100%" border="0" cellpadding="10" cellspacing="0">
			<tr>
				<td valign="top">
					<h3>Billing Address</h3>
					<p>#BillingAddress#</p>
				</td>
				<td valign="top">
					<h3>Shipping Address</h3>
					<cfif qOrder.ship2billing IS true>
						(same as billing address)
					<cfelse>
						<p>#ShippingAddress#</p>
					</cfif>
				</td>
			</tr>
			</table>
			<cfif NOT qOrder.isCompleted IS true><p><a href="cart-addresses.cfm">edit</a></p></cfif>
		</cfoutput></cf_sebField>
	</cf_sebGroup>
<cfelse>
	<cf_sebGroup label="Billing Address" id="group-billaddress">
		<cf_sebField name="Bill_FirstName">
		<cf_sebField name="Bill_LastName">
		<cf_sebField name="Bill_Address1">
		<cf_sebField name="Bill_Address2">
		<cf_sebField name="Bill_City">
		<cf_sebField name="Bill_StateProvinceID">
		<cf_sebField name="Bill_PostalCode">
	</cf_sebGroup>
	<cf_sebField type="custom1">
	<input type="checkbox" name="ship2billing" id="ship2billing" value="1"<cfif qOrder.ship2billing IS true> checked="checked"</cfif> /> <label for="ship2billing">Ship to billing address</label>
	</cf_sebField>
	<cf_sebGroup label="Shipping Address" id="group-shipaddress">
		<cf_sebField name="Ship_FirstName" isRequiredOnServer="#isShipRequired#">
		<cf_sebField name="Ship_LastName" isRequiredOnServer="#isShipRequired#">
		<cf_sebField name="Ship_Address1" isRequiredOnServer="#isShipRequired#">
		<cf_sebField name="Ship_Address2">
		<cf_sebField name="Ship_City" isRequiredOnServer="#isShipRequired#">
		<cf_sebField name="Ship_StateProvinceID" isRequiredOnServer="#isShipRequired#">
		<cf_sebField name="Ship_PostalCode" isRequiredOnServer="#isShipRequired#">
	</cf_sebGroup>
</cfif>