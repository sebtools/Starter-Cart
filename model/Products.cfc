<cfcomponent displayname="Products" extends="com.sebtools.Records" output="no">

<cffunction name="getCartItemStruct" access="public" returntype="any" output="false" hint="">
	<cfargument name="ProductID" type="numeric" required="yes">
	
	<cfset var qProduct = getProduct(arguments.ProductID)>
	<cfset var sResult = StructNew()>
	
	<cfoutput query="qProduct">
		<cfscript>
		sResult["ProductIdentifier"] = "prod:#ProductID#";
		sResult["Price"] = Price;
		sResult["ProductName"] = "#ProductName#";
		sResult["LinkAdmin"] = "/admin/cart/product-edit.cfm?id=#ProductID#";
		sResult["LinkPublic"] = "/products/product.cfm?id=#ProductID#";
		</cfscript>
	</cfoutput>
	
	<cfreturn sResult>
</cffunction>

<cffunction name="saveProduct" access="public" returntype="string" output="no" hint="I save one Product.">
	
	<cfset var result = saveRecord(argumentCollection=arguments)>
	<cfset var qProduct = getProduct(result)>
	
	<cfset variables.StarterCart.updateItems(argumentcollection=getCartItemStruct(result))>
	
	<cfreturn result>
</cffunction>

</cfcomponent>