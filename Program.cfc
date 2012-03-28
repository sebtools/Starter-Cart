<cfcomponent output="false">
	
<cffunction name="config" access="public" returntype="void" output="no">
	<cfargument name="Config" type="any" required="yes">
	
	<cfset Config.paramSetting("Cart_TestMode",true)>
	<cfset Config.paramSetting("Cart_CartType","multi-page")>
	
	<cfset sGatewayConfig = StructNew()>
	<cfset sGatewayConfig["path"] = "bogus.gateway">
	<cfset sGatewayConfig["Username"] = "">
	<cfset sGatewayConfig["Password"] = "">
	<cfset sGatewayConfig["TestMode"] = Config.getSetting("Cart_TestMode")>
	
	<cfset Config.paramSetting("Cart_GatewayConfig",sGatewayConfig)>
	<cfset Config.paramSetting("Cart_ErrorEmail","")>
	
</cffunction>

<cffunction name="components" access="public" returntype="void" output="yes">
<program name="Cart">
	<components>
		<component name="cfpayment" path="cfpayment.api.core">
			<argument name="config" arg="Cart_GatewayConfig" />
		</component>
		<component name="StarterCart" path="[path_component]model.StarterCart">
			<argument name="Manager" />
			<argument name="cfpayment" />
			<argument name="NoticeMgr" ifmissing="skiparg" />
			<argument name="Scheduler" ifmissing="skiparg" />
			<argument name="ErrorEmail" arg="Cart_ErrorEmail" />
		</component>
	</components>
</program>
</cffunction>

<cffunction name="links" access="public" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><?xml version="1.0"?>
	<program>
		<link label="Orders" url="order-list.cfm" />
		<link label="Discounts" url="discount-list.cfm" />
		<link label="Customers" url="customer-list.cfm" />
		<link label="Products" url="product-list.cfm" />
		<!-- <link label="Shippers" url="shipper-list.cfm" /> -->
	</program>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

</cfcomponent>