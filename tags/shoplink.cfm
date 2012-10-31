<cfsilent>
<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cfif StructKeyExists(Caller,"ShopPage")>
	<cfparam name="attributes.ShopPage" type="string" default="#Caller.ShopPage#">
<cfelse>
	<cfparam name="attributes.ShopPage" type="string">
</cfif>
<cfif StructKeyExists(Caller,"ShopText")>
	<cfparam name="attributes.LinkText" type="string" default="#Caller.ShopText#">
<cfelse>
	<cfparam name="attributes.LinkText" type="string" default="Continue Shopping">
</cfif>
</cfsilent><cfoutput><p class="cart-no-print"><a href="#attributes.ShopPage#">#attributes.LinkText#</a></p></cfoutput>