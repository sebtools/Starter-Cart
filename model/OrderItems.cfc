<cfcomponent displayname="Order Items" extends="com.sebtools.Records" output="no">

<cffunction name="getOrderItemID" access="public" returntype="numeric" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="recursed" type="boolean" default="false">
	
	<cfset var result = 0>
	<cfset var qOrderItems = variables.Manager.getRecords(tablename=variables.table,data=arguments,fieldlist="OrderItemID")>
	
	<cfif qOrderItems.RecordCount GT 1 AND NOT arguments.recursed>
		<cfset mergeOrderItems(arguments.ProductIdentifier)>
		<cfset result = getOrderItemID(arguments.OrderID,arguments.ProductIdentifier,true)>
	<cfelseif qOrderItems.RecordCount EQ 1>
		<cfset result = qOrderItems.OrderItemID>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getOrderItems" access="public" returntype="query" output="no" hint="I return all of the OrderItems.">
	
	<cfset var qOrderItems = getRecords(argumentCollection=arguments)>
	<cfset var NewLinkAdmin = "">
	
	<cfif ListFindNoCase(qOrderItems.ColumnList,"LinkAdmin") AND ListFindNoCase(qOrderItems.ColumnList,"OrderID")>
		<cfloop query="qOrderItems">
			<cfif  Len(Trim(LinkAdmin))>
				<cfif FindNoCase("[orderid]",LinkAdmin,1)>
					<cfset NewLinkAdmin = ReplaceNoCase(LinkAdmin,"[orderid]",OrderID,"ALL")>
				<cfelseif ListLen(LinkAdmin,"?") GT 1>
					<cfset NewLinkAdmin = "#LinkAdmin#&order=#OrderID#">
				<cfelse>
					<cfset NewLinkAdmin = "#LinkAdmin#?order=#OrderID#">
				</cfif>
				<cfset QuerySetCell(qOrderItems,"LinkAdmin",NewLinkAdmin,CurrentRow)>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn qOrderItems>
</cffunction>

<cffunction name="mergeOrderItems" access="public" returntype="void" output="false" hint="">
	<cfargument name="ProductIdentifier" type="string" required="yes">

	<cfset var qOrderItems = getOrderItems(argumentCollection=arguments)>
	<cfset var sOrderItems = StructNew()>
	
	<!--- Create merged order item --->
	<cfset sOrderItems["ProductIdentifier"] = arguments.ProductIdentifier>
	<cfset sOrderItems["ProductName"] = qOrderItems["ProductName"][qOrderItems.RecordCount]>
	<cfset sOrderItems["ProductInfo"] = qOrderItems["ProductName"][qOrderItems.RecordCount]>
	<cfset sOrderItems["Price"] = qOrderItems["Price"][qOrderItems.RecordCount]>
	<cfset sOrderItems["Quantity"] = 0>
	<cfoutput query="qOrderItems">
		<cfset sOrderItems["Quantity"] = Quantity>
	</cfoutput>
	
	<!--- Ditch previous order items --->
	<cfset variables.DataMgr.deleteRecords(tablename=variables.table,data=arguments)>
	
	<!--- Add inserted order items --->
	<cfset variables.DataMgr.insertRecord(tablename=variables.table,data=sOrderItems)>
	
</cffunction>

<cffunction name="saveOrderItem" access="public" returntype="string" output="no" hint="I save one OrderItem.">
	
	<cfset var result = 0>
	
	<cftimer type="debug" label="Get Order Item ID">
		<cfif StructKeyExists(arguments,"OrderID") AND StructKeyExists(arguments,"ProductIdentifier") AND NOT ( StructKeyExists(arguments,"OrderItemID") AND isNumeric(arguments.OrderItemID) )>
			<cfset arguments.OrderItemID = getOrderItemID(OrderID=arguments.OrderID,ProductIdentifier=arguments.ProductIdentifier)>
		</cfif>
	</cftimer>
	
	<cftimer type="debug" label="Save Order Item Record">
		<cfset result = saveRecord(argumentCollection=arguments)>
	</cftimer>
	
	<cfif StructKeyExists(arguments,"Quantity") AND arguments.Quantity EQ 0>
		<cfset removeOrderItem(result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="updateItems" access="public" returntype="any" output="false" hint="">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="Price" type="numeric" required="no">
	<cfargument name="ProductName" type="string" required="no">
	<cfargument name="ProductInfo" type="string" required="no">
	<cfargument name="LinkAdmin" type="string" required="no">
	<cfargument name="LinkPublic" type="string" required="no">
	
	<cfset var sSet = StructNew()>
	<cfset var sWhere = StructNew()>
	<cfset var qOrderItems = 0>
	<cfset var setfields = "Price,ProductName,ProductInfo,LinkAdmin,LinkPublic">
	<cfset var setfieldname = "">
	
	<cfloop list="#setfields#" index="setfieldname">
		<cfif StructKeyExists(arguments,setfieldname)>
			<cfset sSet[setfieldname] = arguments[setfieldname]>
		</cfif>
	</cfloop>
	
	<cfset sWhere["Status"] = "Pending">
	<cfset sWhere["ProductIdentifier"] = arguments.ProductIdentifier>
	
	<cfset qOrderItems = variables.DataMgr.getRecords(tablename=variables.table,data=sWhere,fieldlist="OrderID",orderby="OrderID")>
	
	<cfset variables.DataMgr.updateRecords(tablename=variables.table,data_set=sSet,data_where=sWhere)>
	
	<cfif StructKeyExists(arguments,"Price")>
		<cfoutput query="qOrderItems" group="OrderID">
			<cfset variables.StarterCart.Orders.updateOrderTotal(OrderID)>
		</cfoutput>
	</cfif>
	
</cffunction>

<cffunction name="updateItemPrices" access="public" returntype="any" output="false" hint="">
	<cfargument name="ProductIdentifier" type="string" required="yes">
	<cfargument name="Price" type="numeric" required="yes">
	
	<cfset updateItems(ProductIdentifier=arguments.ProductIdentifier,Price=arguments.Price)>
	
</cffunction>

</cfcomponent>