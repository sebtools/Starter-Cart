<cf_PageController>

<cf_layout title="#qProduct.ProductName#">
<cf_layout showTitle="true">

<cfoutput query="qProduct">
#ProductDescription#

<form action="/checkout/cart-add-item.cfm" method="post">
	<input type="hidden" name="ProductIdentifier" value="prod:#ProductID#">
	<input type="submit" value="Add to Cart">
</form>
</cfoutput>

<cf_layout>