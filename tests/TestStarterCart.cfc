<cfcomponent displayname="Starter Cart" extends="com.sebtools.RecordsTester">

<cffunction name="setUp" access="public" returntype="void" output="no">
	
	<cfset loadExternalVars("StarterCart")>
	<cfset loadExternalVars(varlist="NoticeMgr",skipmissing=true)>
	
</cffunction>
<!---
Test correct discount calculation

--->
<!---<cffunction name="shouldXXX" access="public" mxunit:transaction="rollback" output="no" hint="XXX">
	
	<cfset fail("Test not yet implemented")>
	
</cffunction>--->

</cfcomponent>