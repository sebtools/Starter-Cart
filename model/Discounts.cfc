<cfcomponent displayname="Discounts" extends="com.sebtools.Records" output="no">

<cffunction name="getActiveDiscounts" access="public" returntype="query" output="no" hint="I return the active Discounts.">
	
	<cfset var aFilters = ArrayNew(1)>
	
	<cfreturn variables.Manager.getRecords(tablename=variables.table,data=arguments)>
</cffunction>

<cffunction name="getDiscountAmount" access="public" returntype="numeric" output="false" hint="">
	<cfargument name="DiscountID" type="string" required="yes">
	<cfargument name="OrderTotal" type="numeric" required="yes">
	
	<cfset var qDiscount = 0>
	<cfset var result = 0>
	
	<cfif isNumeric(arguments.DiscountID) AND arguments.DiscountID GT 0>
		<cfset qDiscount = getDiscount(DiscountID=arguments.DiscountID,fieldlist="DiscountID,DiscountAmount,DiscountPercent")>
		<cfset result = calcDiscount(arguments.OrderTotal,Val(qDiscount.DiscountAmount),Val(qDiscount.DiscountPercent))>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getDiscountInfo" access="public" returntype="struct" output="false" hint="">
	<cfargument name="PromoCode" type="string" required="yes">
	<cfargument name="OrderTotal" type="numeric" required="yes">
	
	<cfset var sDiscountInfo = StructNew()>
	<cfset var qDiscounts = getDiscounts(PromoCode=arguments.PromoCode)>
	<cfset var amt = 0>
	
	<cfset sDiscountInfo["DiscountID"] = 0>
	<cfset sDiscountInfo["Amount"] = 0>
	<cfset sDiscountInfo["DiscountCode"] = qDiscounts.PromoCode>
	
	<cfoutput query="qDiscounts">
		<cfif
				( DateBegin LTE now() OR NOT isDate(DateBegin) )
			AND	( DateEnd GTE now() OR NOT isDate(DateEnd) )
			AND	( MinPurchaseTotal GTE arguments.OrderTotal OR MinPurchaseTotal EQ 0 OR NOT Len(MinPurchaseTotal) )
		>
			
			<cfset amt = calcDiscount(arguments.OrderTotal,Val(DiscountAmount),Val(DiscountPercent))>
			
			<cfif amt GT sDiscountInfo["Amount"]>
				<cfset sDiscountInfo["DiscountID"] = DiscountID>
				<cfset sDiscountInfo["Amount"] = amt>
			</cfif>
			
		</cfif>
	</cfoutput>
	
	<cfreturn sDiscountInfo>
</cffunction>

<cffunction name="hasDiscounts" access="public" returntype="boolean" output="false" hint="I indicate whether or not the system has any active discounts.">
	
	<cfset var today = DateFormat(now(),"yyyy-mm-dd")>
	<cfset var qDiscounts = 0>
	
	<cfif NOT ( StructKeyExists(variables,"DateHasDiscount") AND variables.DateHasDiscount EQ today )>
		<cfset qDiscounts = variables.DataMgr.getRecords(tablename="cartDiscounts",fieldlist="DiscountID,DateBegin,DateEnd")>
		<cfset variables.HasDiscounts = false>
		<cfloop query="qDiscounts">
			<cfif
					( DateBegin LTE now() OR NOT isDate(DateBegin) )
				AND	( DateEnd GTE now() OR NOT isDate(DateEnd) )
			>
				<cfset variables.HasDiscounts = true>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfset variables.DateHasDiscount = today>
	</cfif>
	
	<cfreturn variables.HasDiscounts>
</cffunction>

<cffunction name="removeDiscount" access="public" returntype="void" output="no" hint="I delete the given Discount.">
	<cfargument name="DiscountID" type="string" required="yes">
	
	<cfset removeRecord(argumentCollection=arguments)>
	
	<cfset resetHasDiscounts()>
	
</cffunction>

<cffunction name="saveDiscount" access="public" returntype="string" output="no" hint="I save one Discount.">
	
	<cfset var result = saveRecord(argumentCollection=arguments)>
	
	<cfset resetHasDiscounts()>
	
	<cfset variables.StarterCart.Orders.updateOrderTotals(DiscountID=result)>
	
	<cfreturn result>
</cffunction>

<cffunction name="calcDiscount" access="private" returntype="numeric" output="false" hint="">
	<cfargument name="OrderTotal" type="numeric" required="yes">
	<cfargument name="DiscountAmount" type="numeric" required="yes">
	<cfargument name="DiscountPercent" type="numeric" required="yes">
	
	<cfset var result = 0>
	
	<cfif DiscountPercent GT 0>
		<cfset result = ( arguments.OrderTotal * arguments.DiscountPercent ) / 100>
	<cfelseif DiscountAmount GT 0>
		<cfset result = arguments.DiscountAmount>
	</cfif>
	
	<!--- round off result --->
	<cfset result = variables.StarterCart.CentsRound(result)>
	
	<cfreturn result>
</cffunction>

<cffunction name="resetHasDiscounts" access="private" returntype="void" output="false">
	
	<cfset StructDelete(variables,"DateHasDiscount")>
	<cfset StructDelete(variables,"HasDiscounts")>
	
</cffunction>

</cfcomponent>