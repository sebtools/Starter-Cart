<cfcomponent displayname="Gateway" extends="cfpayment.api.gateway.base" output="false" hint="Bogus gateway demonstrates an implementation">

	<!--- gateway specific variables --->
	<cfset variables.cfpayment.GATEWAYID = "7" />
	<cfset variables.cfpayment.GATEWAY_NAME = "Authorize.Net Gateway" />
	<cfset variables.cfpayment.GATEWAY_VERSION = "1.0 Development" />
	<cfset variables.cfpayment.GATEWAY_TEST_URL = "https://secure.authorize.net/gateway/transact.dll" />
	<cfset variables.cfpayment.GATEWAY_LIVE_URL = "https://secure.authorize.net/gateway/transact.dll" />


	<cffunction name="init" access="public" output="false" returntype="any">
		<cfset super.init(argumentCollection = arguments) />
		<!--- setup static variables --->
		<cfreturn this />
	</cffunction>

	<cffunction name="purchase" access="public" output="false" returntype="any" hint="Perform an authorization immediately followed by a capture">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" />

		<cfset authorize(argumentCollection=arguments)>
		
		<cfreturn capture(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="authorize" access="public" output="false" returntype="any" hint="Verifies payment details with merchant bank">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" />

		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	</cffunction>

	<cffunction name="capture" access="public" output="false" returntype="any" hint="Confirms an authorization with direction to charge the account">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="authorization" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" />

		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	</cffunction>

	<cffunction name="credit" access="public" output="false" returntype="any" hint="Returns an amount back to the previously charged account.  Only for use with captured transactions.">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="transactionid" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" />

		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	</cffunction>

	<cffunction name="void" access="public" output="false" returntype="any" hint="Cancels a previously captured transaction that has not yet settled">
		<cfargument name="transactionid" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" />

		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	</cffunction>

	<cffunction name="search" access="public" output="false" returntype="any" hint="Find transactions using gateway-supported criteria">
		<cfargument name="options" type="struct" required="true" />

		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	</cffunction>

	<cffunction name="status" access="public" output="false" returntype="any" hint="Reconstruct a response object for a previously executed transaction">
	
		<cfthrow message="Method not implemented." type="cfpayment.MethodNotImplemented" />
	
	</cffunction>


	<!--- this is a credit card gateway --->
	<cffunction name="getIsCCEnabled" output="false" access="public" returntype="boolean" hint="determine whether or not this gateway can accept credit card transactions">
		<cfreturn true />
	</cffunction>

</cfcomponent>