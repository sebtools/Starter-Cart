<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cf_layout>
	<link rel="stylesheet" type="text/css" href="cart-review-print.css" media="print" />
	<script type="text/javascript" src="cart.js"></script>
	<script type="text/javascript" src="cart-review.js"></script>
<cf_layout showTitle="true">

<cf_sebForm action="">
	<cart:items>
	<cart:addresses>
	<cart:payment>
	<cf_sebField id="cart-print" name="print" type="button" label="Print" onclick="window.print(); return false;" style="display:none;">
</cf_sebForm>

<p class="cart-no-print"><a href="/">Return to Home Page</a></p>
<cart:shoplink>

<cf_layout>