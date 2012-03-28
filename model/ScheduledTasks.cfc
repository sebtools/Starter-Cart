<cfcomponent displayname="Scheduled Tasks" output="no">

<cffunction name="init" access="public" returntype="any" output="false" hint="">
	<cfargument name="StarterCart" type="any" required="yes">
	
	<cfset variables.StarterCart = arguments.StarterCart>
	
	<cfif StructKeyExists(variables.StarterCart,"Scheduler")>
		<cfset loadCustomTasks()>
	</cfif>
	
	<cfreturn This>
</cffunction>

<cffunction name="runTasks" access="public" returntype="any" output="false" hint="">
	
	<cfset checkOrderCustomerIssue()>
	
	<cfset runCustomTasks()>
	
</cffunction>

<cffunction name="checkOrderCustomerIssue" access="private" returntype="any" output="false" hint="">
	
	<cfset var qNoOrderCustomers = variables.StarterCart.Customers.getCustomers(NumOrders=0)>
	
	<cfif qNoOrderCustomers.RecordCount>
		<cfset variables.StarterCart.sendEmailAlert("Cart Problem","Customer found with no order.")>
	</cfif>
	
</cffunction>

<cffunction name="loadCustomTasks" access="private" returntype="any" output="false" hint="">

</cffunction>

<cffunction name="runCustomTasks" access="private" returntype="any" output="false" hint="">

</cffunction>

</cfcomponent>