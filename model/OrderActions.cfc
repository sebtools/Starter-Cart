<cfcomponent displayname="Order Actions" extends="com.sebtools.Records" output="no">

<cffunction name="addOrderAction" access="public" returntype="numeric" output="false" hint="">
	<cfargument name="OrderID" type="numeric" required="yes">
	<cfargument name="Action" type="string" required="yes">
	<cfargument name="Notes" type="string" required="no">
	
	<cfset var result = 0>
	
	<cfset saveOrderInfo(argumentCollection=arguments)>
	
	<!--- Always an insert, every action should get recorded even if a matching one has already been taken --->
	<cfset result = variables.DataMgr.insertRecord(variables.table,arguments)>
	
	<!--- Send notice if one exists for this action --->
	<cfif variables.StarterCart.Notices.hasActionNotice(arguments.Action)>
		<cfset sendOrderActionNotice(result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getOrderAction" access="public" returntype="query" output="no" hint="I return the requested OrderAction.">
	<cfargument name="OrderActionID" type="string" required="yes">
	
	<cfreturn QueryAddCalculatedColumns(getRecord(argumentCollection=arguments))>
</cffunction>

<cffunction name="getOrderActionMessages" access="public" returntype="query" output="no" hint="I return the requested OrderAction.">
	<cfargument name="OrderActionID" type="string" required="yes">
	
	<cfreturn variables.Manager.getRecords(tablename="cartOrderActionMessages",data=arguments)>
</cffunction>

<cffunction name="getOrderActions" access="public" returntype="query" output="no" hint="I save one OrderAction.">
	
	<cfset var qOrderActions = getRecords(argumentCollection=arguments)>
	
	<cfreturn QueryAddCalculatedColumns(qOrderActions)>
</cffunction>

<cffunction name="saveOrderAction" access="public" returntype="numeric" output="no" hint="I return all of the OrderActions.">
	
	<cfset var result = saveRecord(argumentCollection=arguments)>
	<cfset var sOrder = StructNew()>
	
	<cfset saveOrderInfo(argumentCollection=arguments)>
	
	<!--- Send notice if this is a new action for an order --->
	<cfif
			( StructKeyExists(arguments,"OrderID") AND isNumeric(arguments.OrderID) AND arguments.OrderID GT 0 )
		AND	NOT ( StructKeyExists(arguments,"OrderActionID") AND isNumeric(arguments.OrderActionID) AND arguments.OrderActionID GT 0 )
	>
		<cfset sendOrderActionNotice(result)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="sendOrderActionNotice" access="public" returntype="boolean" output="false" hint="">
	<cfargument name="OrderActionID" type="numeric" required="yes">
	
	<cfset var qOrderAction = variables.DataMgr.getRecord(tablename=variables.table,data=arguments,fieldlist="OrderActionID,OrderID,Action")>
	<cfset var result = false>
	
	<cfset result = variables.StarterCart.Notices.sendNotice(qOrderAction.OrderID,qOrderAction.Action)>
	
	<cfif result>
		<cfset variables.DataMgr.insertRecord(variables.StarterCart.OrderActionMessages.getTableVariable(),arguments)>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="QueryAddCalculatedColumns" access="private" returntype="any" output="false" hint="">
	<cfargument name="query" type="query" required="yes">
	
	<cfset var aHasExtraInfo = ArrayNew(1)>
	<cfset var aMaskedCardNumber = ArrayNew(1)>
	
	<!---<cfif ListFindNoCase(arguments.query.ColumnList,"hasExtraInfo")>--->
		<cfloop query="arguments.query">
			<cfif
					( ListFindNoCase(arguments.query.ColumnList,"Notes") AND Len(Notes) )
				OR	( ListFindNoCase(arguments.query.ColumnList,"ShipperTrackingNumber") AND Len(ShipperTrackingNumber) )
				OR	( ListFindNoCase(arguments.query.ColumnList,"PaymentTransactionNumber") AND Len(PaymentTransactionNumber) )
				OR	( ListFindNoCase(arguments.query.ColumnList,"CardLastFour") AND Len(CardLastFour) )
				OR	( ListFindNoCase(arguments.query.ColumnList,"LastMessageSent") AND isDate(LastMessageSent) )
				OR	( ListFindNoCase(arguments.query.ColumnList,"Action") AND variables.StarterCart.Notices.hasActionNotice(Action) )
			>
				<cfset ArrayAppend(aHasExtraInfo,true)>
			<cfelse>
				<cfset ArrayAppend(aHasExtraInfo,false)>
			</cfif>
		</cfloop>
		<cfset QueryAddColumn(arguments.query,"hasExtraInfo","Bit",aHasExtraInfo)>
	<!---</cfif>--->
	
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

<cffunction name="saveOrderInfo" access="private" returntype="void" output="false" hint="">
	
	<cfset var sOrder = StructNew()>
	<cfset var OrderFields = "ShipperTrackingNumber,PaymentTransactionNumber,CreditCardID,CardLastFour,CardLength">
	<cfset var field = "">
	
	<cfif StructKeyExists(arguments,"OrderID")>
		<cfloop list="#OrderFields#" index="field">
			<cfif StructKeyExists(arguments,field) AND Len(arguments[field])>
				<cfset sOrder[field] = arguments[field]>
			</cfif>
		</cfloop>
		<cfif StructCount(sOrder)>
			<cfset sOrder["OrderID"] = arguments.OrderID>
			<cfset sOrder["total"] = false>
			<cfset variables.StarterCart.Orders.saveOrder(argumentCollection=sOrder)>
		</cfif>
	</cfif>
	
</cffunction>

</cfcomponent>