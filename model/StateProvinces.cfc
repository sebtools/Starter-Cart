<cfcomponent displayname="State Provinces" extends="com.sebtools.Records" output="no">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Manager" type="any" required="yes">
	
	<cfset initInternal(argumentCollection=arguments)>
	
	<cfset getStateProvinces()>
	
	<cfreturn this>
</cffunction>


<cffunction name="getStateProvinces" access="public" returntype="query" output="no" hint="I return all of the StateProvinces.">
	
	<cfset var qStateProvinces = 0>
	
	<cfif StructCount(arguments)>
		<cfset qStateProvinces = getRecords(argumentCollection=arguments)>
	<cfelse>
		<cfif NOT StructKeyExists(variables,"qStateProvinces")>
			<cfset variables.qStateProvinces = getRecords(argumentCollection=arguments)>
		</cfif>
		<cfset qStateProvinces = variables.qStateProvinces>
	</cfif>
	
	<cfreturn qStateProvinces>
</cffunction>

<cffunction name="removeStateProvince" access="public" returntype="void" output="no" hint="I delete the given StateProvince.">
	<cfargument name="StateProvinceID" type="string" required="yes">
	
	<cfset removeRecord(argumentCollection=arguments)>
	
	<cfset resetStateProvinces()>
	
</cffunction>

<cffunction name="saveStateProvince" access="public" returntype="string" output="no" hint="I save one StateProvince.">
	
	<cfif StructKeyExists(arguments,"TaxPercent")>
		<cfif arguments.TaxPercent GT 100>
			<cfset variables.StarterCart.throwError("Tax Percent can not be more than 100%.")>
		</cfif>
	</cfif>
	
	<cfset resetStateProvinces()>
	
	<cfreturn saveRecord(argumentCollection=arguments)>
</cffunction>

<cffunction name="resetStateProvinces" access="private" returntype="void" output="no">
	<cfset StructDelete(variables,"qStateProvinces")>
</cffunction>

</cfcomponent>