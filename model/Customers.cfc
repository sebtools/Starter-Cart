<cfcomponent displayname="Customers" extends="com.sebtools.Records" output="no">

<cffunction name="getCustomers" access="public" returntype="query" output="no" hint="I return all of the Customers.">
	<cfargument name="WithOrdersOnly" type="boolean" default="true">
	
	<cfif arguments.WithOrdersOnly IS true>
		<cfset arguments.HasOrders = true>
	</cfif>
	
	<cfreturn getRecords(argumentCollection=arguments)>
</cffunction>

</cfcomponent>