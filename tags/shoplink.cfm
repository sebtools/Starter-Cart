<cfsilent>
<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cfif StructKeyExists(Caller,"ShopPage")>
	<cfparam name="attributes.ShopPage" type="string" default="#Caller.ShopPage#">
<cfelse>
	<cfparam name="attributes.ShopPage" type="string">
</cfif>
<cfparam name="attributes.LinkText" type="string" default="Continue Shopping">
</cfsilent><cfoutput><p class="cart-no-print"><a href="#attributes.ShopPage#">#attributes.LinkText#</a></p></cfoutput>