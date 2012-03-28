<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cf_layout>
	<script type="text/javascript" src="cart.js"></script>
<cf_layout showTitle="true">

<cart:step>

<cf_sebForm>
	<cart:items isReview="true">
	<cart:addresses isReview="true">
	<cart:payment>
	<cf_sebField type="Submit" label="Complete Order">
</cf_sebForm>

<cart:step>

<cf_layout>