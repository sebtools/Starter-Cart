<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cf_sebForm>
	<cf_sebField name="DiscountName">
	<cf_sebField name="PromoCode">
	<cf_sebField name="DiscountAmount">
	<cf_sebField name="DiscountPercent" input_suffix="%">	
	<cf_sebField name="DateBegin">
	<cf_sebField name="DateEnd">
	<!--- <cf_sebField name="Description">
	<cf_sebField name="MinPurchaseTotal">
	<cf_sebField name="MaxUses"> --->
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

<cfif Action IS "Edit">
	<cf_layout include="order-list.cfm">
</cfif>

<cf_layout>