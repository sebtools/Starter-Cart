<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cf_layout title="Cart">
	<script type="text/javascript" src="cart.js"></script>
<cf_layout>

<cf_sebForm>
	<cf_sebGroup label="Items">
		<cart:items>
	</cf_sebGroup>
	<cart:addresses>
	<cf_sebGroup label="Payment">
		<cart:payment>
	</cf_sebGroup>
	<cf_sebField type="Submit" label="Checkout">
</cf_sebForm>

<cf_layout>