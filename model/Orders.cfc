<cfcomponent displayname="Orders" extends="com.sebtools.Records" output="no">

<cffunction name="addOrder" access="package" returntype="numeric" output="false" hint="">
	<cfargument name="SubTotal" type="numeric" default="0">
	
	<cfset var result = variables.DataMgr.insertRecord(variables.table,arguments)>
	
	<cfset variables.StarterCart.recordAction(result,"Start")>
	
	<cfreturn result>
</cffunction>

<cffunction name="getOrder" access="public" returntype="query" output="no" hint="I return the requested Order.">
	<cfargument name="OrderID" type="string" required="yes">
	
	<cfreturn QueryAddCalculatedColumns(getRecord(argumentCollection=arguments))>
</cffunction>

<cffunction name="getOrders" access="public" returntype="query" output="no" hint="I return all of the Orders.">
	
	<cfreturn QueryAddCalculatedColumns(getRecords(argumentCollection=arguments))>
</cffunction>

<cffunction name="getTrends" access="public" returntype="query" output="false" hint="">
	
	<cfset var qTrends = 0>
	<cfset var sWhere = StructNew()>
	
	<cfset sWhere["isCompleted"] = true>
	
	<cf_DMQuery name="qTrends" DataMgr="#variables.DataMgr#"><cfoutput>
	SELECT		year(DatePlaced) AS orderYear,
				month(DatePlaced) AS orderMonth,
				'' AS OrderMonthYear,
				count(*) AS NumOrders,
				sum(OrderTotal) AS OrdersTotal
	FROM		#variables.table#
	WHERE		1 = 1
	<cf_DMSQL method="getWhereSQL" tablename="#variables.table#" data="#sWhere#">
	GROUP BY	year(DatePlaced), month(DatePlaced)
	ORDER BY	year(DatePlaced), month(DatePlaced)
	</cfoutput></cf_DMQuery>
	
	<cfloop query="qTrends">
		<cfset QuerySetcell(qTrends,"OrderMonthYear",DateFormat(CreateDate(orderYear,orderMonth,1),"mmm yyyy"),CurrentRow)>
	</cfloop>
	
	<cfreturn qTrends>
</cffunction>

<cffunction name="isCompleted" access="public" returntype="boolean" output="no">
	<cfargument name="OrderID" type="string" required="yes">
	
	<cfset var qOrder = variables.DataMgr.getRecord(tablename=variables.table,data=arguments,fieldlist="isCompleted")>
	
	<cfreturn qOrder.isCompleted>
</cffunction>

<cffunction name="saveOrder" access="public" returntype="string" output="no" hint="I save one Order.">
	
	<cfset var result = 0>
	
	<cfset result = saveRecord(argumentCollection=arguments)>
	
	<cfif NOT ( StructKeyExists(arguments,"total") AND arguments.total IS false )>
		<cfset updateOrderTotal(result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="updateOrderTotal" access="public" returntype="any" output="false" hint="">
	<cfargument name="OrderID" type="any" required="yes">
	
	<cfset var qOrder = variables.Manager.getRecord(tablename=variables.table,data=arguments,fieldlist="Status,DiscountID,SubTotal")>
	<cfset var qOrderItems = variables.StarterCart.OrderItems.getOrderItems(OrderID=arguments.OrderID)>
	<cfset var qBillingAddress = variables.StarterCart.getBillingAddress(arguments.OrderID)>
	<cfset var qStateProvince = 0>
	<cfset var sOrder = StructNew()>
	<cfset var total = 0>
	
	<cfif qOrder.Status EQ "Pending">
		<cfset sOrder["OrderID"] = arguments.OrderID>
		
		<!--- Calculate subtotal --->
		<cfset sOrder["Subtotal"] = 0>
		<cfoutput query="qOrderItems">
			<cfset sOrder["Subtotal"] = sOrder["Subtotal"] + ( Price * Int(Quantity) )>
		</cfoutput>
		<cfset total = total + sOrder["Subtotal"]>
		
		<!--- Calculate shipping cost --->
		<cfset sOrder["ShippingCost"] = getShippingCost(arguments.OrderID)>
		<cfset total = total + sOrder["ShippingCost"]>
		
		<!--- Calculate discount amount --->
		<cfset sOrder["DiscountAmount"] = variables.StarterCart.Discounts.getDiscountAmount(qOrder.DiscountID,qOrder.SubTotal)>
		<cfset total = total - sOrder["DiscountAmount"]>
		
		<!--- Calculate tax --->
		<cfset sOrder["Tax"] = 0>
		<cfif qBillingAddress.RecordCount AND Len(qBillingAddress.StateCode)>
			<cfset qStateProvince = variables.StarterCart.StateProvinces.getStateProvinces(Code=qBillingAddress.StateCode)>
			<cfif qStateProvince.RecordCount EQ 1 AND isNumeric(qStateProvince.TaxPercent) AND qStateProvince.TaxPercent GT 0>
				<cfset sOrder["Tax"] = ( total * qStateProvince.TaxPercent ) / 100>
				<cfset sOrder["Tax"] = variables.StarterCart.CentsRound(sOrder["Tax"])>
			</cfif>
		</cfif>
		<cfset total = total + sOrder["Tax"]>
		
		<!--- Calculate order total --->
		<cfset sOrder["OrderTotal"] = variables.StarterCart.CentsRound(total)>
		
		<cfset variables.DataMgr.updateRecord(variables.table,sOrder)>
	</cfif>
	
</cffunction>

<cffunction name="updateOrderTotals" access="public" returntype="any" output="false" hint="">
	
	<cfset var qOrders = 0>
	
	<cfset arguments["Status"] = "Pending">
	
	<cfset qOrders = variables.DataMgr.getRecords(tablename=variables.table,data=arguments,fieldlist="OrderID",orderby="OrderID")>
	
	<cfloop query="qOrders">
		<cfset updateOrderTotal(OrderID)>
	</cfloop>
	
</cffunction>

<cffunction name="getShippingCost" access="public" returntype="any" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	
	<cfreturn 0>
</cffunction>

<cffunction name="QueryAddCalculatedColumns" access="private" returntype="any" output="false" hint="">
	<cfargument name="query" type="query" required="yes">
	
	<cfset var aMaskedCardNumber = ArrayNew(1)>
	
	<cfif ListFindNoCase(arguments.query.ColumnList,"CardLastFour")>
		<cfloop query="arguments.query">
			<cfif Len(CardLastFour)>
				<cfset ArrayAppend(aMaskedCardNumber,variables.StarterCart.MaskedCardNumber(CardLastFour,Val(CardLength)))>
			<cfelse>
				<cfset ArrayAppend(aMaskedCardNumber,"")>
			</cfif>
		</cfloop>
		<cfset QueryAddColumn(arguments.query,"MaskedCardNumber","Varchar",aMaskedCardNumber)>
	</cfif>
	
	<cfreturn arguments.query>
</cffunction>

</cfcomponent>