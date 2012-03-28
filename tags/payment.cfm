<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cf_PageController>

<cfif qOrder.isCompleted>
	<cfif Len(qOrder.CreditCard) OR Len(qOrder.MaskedCardNumber)>
	<cf_sebGroup label="Payment Information">
		<cfif Len(qOrder.CreditCard)>
			<cf_sebField name="CreditCard" type="plaintext" label="Credit Card">
		</cfif>
		<cfif Len(qOrder.MaskedCardNumber)>
			<cf_sebField name="MaskedCardNumber" type="plaintext" label="Credit Card Number">
		</cfif>
	</cf_sebGroup>
	</cfif>
<cfelse>
	<cf_sebField name="CreditCardID" label="Credit Card" type="select" CFC_Component="#Application.StarterCart.CreditCards#">
	<cf_sebField name="ccnum" label="Credit Card Number" regex="^\d{13,16}$" stripregex="[^\d]*" required="true" autocomplete="off">
	<cfset ccv_help = '<a href="ccv.cfm" id="cart-ccv-helplink" target="_blank">What''s this?</a>'>
	<cf_sebField name="ccv" label="Security Code" size="4" length="4" regex="\d{3,4}" required="true" autocomplete="off" help="#ccv_help#">
	<cf_sebField name="ccexpire" label="Expiration Date" type="custom1" required="true">
		<cfoutput>
		<select name="ccexpmonth" id="ccexpmonth">
			<option value=""></option><cfloop index="ii" from="1" to="12" step="1">
			<option value="#NumberFormat(ii,"00")#"<cfif StructKeyExists(sebForm.sForm,"ccexpmonth") AND ii EQ sebForm.sForm.ccexpmonth> selected="selected"</cfif>>#NumberFormat(ii,"00")#</option></cfloop>
		</select>
		<select name="ccexpyear" id="ccexpyear">
			<option value=""></option><cfloop index="ii" from="#Year(now())#" to="#Year(now())+9#" step="1">
			<option value="#ii#"<cfif StructKeyExists(sebForm.sForm,"ccexpyear") AND ii EQ sebForm.sForm.ccexpyear> selected="selected"</cfif>>#ii#</option></cfloop>
		</select>
		</cfoutput>
	</cf_sebField>
</cfif>