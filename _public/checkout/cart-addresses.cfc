<cfcomponent extends="_cart" output="no">

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = super.loadData()>
	
	<cfif NOT vars.qOrderItems.RecordCount>
		<cfset go(variables.ShopPage)>
	</cfif>
	
	<cfset StructAppend(vars,loadDefaults(vars.CustomerID))>
	
	<cfset vars.SebFormAttributes.CFC_Method = "saveAddresses">
	
	<cfreturn vars>
</cffunction>

<cffunction name="loadDefaults" access="public" returntype="struct" output="no">
	<cfargument name="CustomerID" type="numeric" required="true">
	
	<cfset var qBillingAddresses = 0>
	<cfset var qCustomer = 0>
	<cfset var vars = StructNew()>
	
	<cfif Arguments.CustomerID>
		<cfset qBillingAddresses = Variables.StarterCart.Orders.getOrders(CustomerID=Arguments.CustomerID,fieldlist="BillingAddressID",distinct=true)>
		<cfif qBillingAddresses.RecordCount EQ 1>
		<cfelse>
			<cfset qCustomer = Variables.StarterCart.Customers.getCustomer(CustomerID=Arguments.CustomerID,fieldlist="CustomerID,FirstName,LastName")>
			
			<cfset vars.sebFields["Bill_FirstName"]["defaultValue"] = qCustomer.FirstName>
			<cfset vars.sebFields["Bill_LastName"]["defaultValue"] = qCustomer.LastName>
		</cfif>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>