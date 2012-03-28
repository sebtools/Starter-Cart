<cfcomponent displayname="Addresses" extends="com.sebtools.Records" output="no">

<cffunction name="getAddressHTML" access="public" returntype="string" output="false" hint="">
	<cfargument name="AddressID" type="numeric" required="yes">
	
	<cfset var result = "">
	<cfset var qAddress = getAddress(arguments.AddressID)>
	
	<cfif Len(Trim(qAddress.Addressee))>
		<cfset result = "#result##qAddress.Addressee#<br/>">
	</cfif>
	<cfif Len(Trim(qAddress.Address1))>
		<cfset result = "#result##qAddress.Address1#<br/>">
	</cfif>
	<cfif Len(Trim(qAddress.Address2))>
		<cfset result = "#result##qAddress.Address2#<br/>">
	</cfif>
	<cfif 	Len(Trim(qAddress.City))
		OR	Len(Trim(qAddress.StateCode))
		OR	Len(Trim(qAddress.PostalCode))
	>
		<cfif Len(Trim(qAddress.City))>
			<cfset result = "#result##qAddress.City#">
		</cfif>
		<cfif Len(Trim(qAddress.StateCode))>
			<cfset result = "#result#, #qAddress.StateCode#">
		</cfif>
		<cfif Len(Trim(qAddress.PostalCode))>
			<cfset result = "#result# #qAddress.PostalCode#">
		</cfif>
		<cfset result = "#result#<br/>">
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="saveAddress" access="public" returntype="string" output="no" hint="I save one Address.">
	
	<cfif
			StructKeyExists(arguments,"Address")
		AND	Len(Trim(arguments.Address))
		AND	NOT (
				StructKeyExists(arguments,"Address1") AND Len(Trim(arguments.Address1))
			)>
		<cfset arguments.Address1 = arguments.Address>
	</cfif>
	
	<cfreturn saveRecord(argumentCollection=arguments)>
</cffunction>

</cfcomponent>