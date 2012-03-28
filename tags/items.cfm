<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cf_PageController>

<cfif sebForm.attributes.Format EQ "table"><tr><td colspan="2"></cfif>
<table width="100%" cellpadding="0" cellspacing="0" id="cart-details" border="1">
<tr id="row-header">
	<th>Item</th>
	<th>Unit Price</th>
	<th>Quantity</th>
	<th>Price</th>
</tr>
<cfoutput query="qOrderItems">
<tr id="row-item-#OrderItemID#">
	<td><cfif isAdmin AND Len(LinkAdmin)><a href="#LinkAdmin#">#ProductName#</a><cfelseif Len(LinkPublic)><a href="#LinkPublic#">#ProductName#</a><cfelse>#ProductName#</cfif><cfif Len(ProductInfo)><br/>#ProductInfo#</cfif></td>
	<td align="right">#DollarFormat(Price)#</td>
	<td align="right"><cfif isReview>#Quantity#<cfelse><input type="text" name="qty_#OrderItemID#" value="#Quantity#" size="3" style="text-align:right"></cfif></td>
	<td align="right"><div id="cart-item-total">#DollarFormat(Price * Quantity)#</div></td>
</tr>
</cfoutput>
<cfoutput query="qOrder">
<cfif SubTotal NEQ OrderTotal>
<tr id="row-subtotal">
	<td colspan="3" align="right">
		Subtotal:
	</td>
	<td align="right"><div id="cart-subtotal">#DollarFormat(SubTotal)#</div></td>
</tr>
</cfif>
<cfif Tax GT 0>
<tr id="row-tax">
	<td colspan="3" align="right">
		Tax:
	</td>
	<td align="right"><div id="cart-tax">#DollarFormat(Tax)#</div></td>
</tr>
</cfif>
<cfif ShippingCost GT 0>
<tr id="row-shipping">
	<td colspan="3" align="right">
		Shipping:
	</td>
	<td align="right"><div id="cart-shipping">#DollarFormat(Val(ShippingCost))#</div></td>
</tr>
</cfif>
<cfif isDiscountable AND ( DiscountAmount GT 0 OR NOT isReview )>
<tr id="row-discount">
	<td colspan="3" align="right">
		<label for="discount-code" style="font-weight:normal;">Discount Code:</label>
		<cfif isReview>#DiscountCode#<cfelse><input type="text" id="discount-code" name="DiscountCode" value="#DiscountCode#" /></cfif>
	</td>
	<td align="right"><div id="cart-discount"><cfif DiscountAmount>#DollarFormat(DiscountAmount)#</cfif></div></td>
</tr>
</cfif>
<!---<cfif TRUE OR qOrderItems.RecordCount NEQ 1 OR SubTotal NEQ OrderTotal>--->
<tr id="row-total">
	<td colspan="3" align="right">
		Total:
	</td>
	<td align="right"><div id="cart-total">#DollarFormat(OrderTotal)#</div></td>
</tr>
<!---</cfif>--->
</cfoutput>
</table>
<cfif NOT isReview><div id="cart-button-update"><input type="submit" name="submit" value="Update Cart"></div></cfif>
<cfif isReview AND NOT qOrder.isCompleted IS true>
	<cfif sebForm.attributes.Format EQ "table"><tr><td></cfif>
	<cf_sebField name="blah" type="custom" label=" ">
		<p><a href="cart-items.cfm">edit</a></p>
	</cf_sebField>
	<cfif sebForm.attributes.Format EQ "table"></td></tr></cfif>
</cfif>