<cfimport prefix="cart" taglib="/admin/cart/tags">
<cf_PageController>

<cfset head = '<link rel="stylesheet" type="text/css" href="cart-review-print.css" media="print" />'>
<cf_Template files_js="cart.js,cart-review.js" showTitle="true" head="#head#">


<input id="cart-print" name="print" type="button" value="Print" onclick="window.print(); return false;" class="cart-no-print" style="margin-top:10px;">
<cf_sebForm action="">
	<cart:items>
	<cart:addresses>
	<cart:payment>
</cf_sebForm>

<p class="cart-no-print"><a href="/">Return to Home Page</a></p>
<cart:shoplink>

</cf_Template>