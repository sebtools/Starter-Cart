<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cf_layout>
	<script type="text/javascript" src="cart.js"></script>
<cf_layout showTitle="true">

<cart:step>

<cf_sebForm>
	<cart:items>
	<cf_sebField type="Submit" label="Checkout">
</cf_sebForm>

<cart:step>
<cart:shoplink>

<cf_layout>