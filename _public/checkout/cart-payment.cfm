<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cf_Template files_js="cart.js" showTitle="true">

<cart:step>

<cf_sebForm showReqMarkHint="true">
	<cart:items isReview="true">
	<cart:addresses isReview="true">
	<cart:payment>
	<cf_sebField type="Submit" label="Complete Order">
</cf_sebForm>

<cart:step>

</cf_Template>