<cfsilent>
<cfif ThisTag.ExecutionMode IS "End"><cfexit method="exittemplate"></cfif>
<cfif StructKeyExists(Caller,"steps")>
	<cfparam name="attributes.steps" type="string" default="#Caller.steps#">
<cfelse>
	<cfparam name="attributes.steps" type="string">
</cfif>
<cfif StructKeyExists(Caller,"step")>
	<cfparam name="attributes.stepnum" type="numeric" default="#Caller.step#">
<cfelse>
	<cfparam name="attributes.stepnum" type="numeric">
</cfif>
<cfset variables.steps = attributes.steps>

<cffunction name="getStepHTML" access="public" returntype="string" output="false" hint="">
	<cfargument name="stepnum" type="numeric" required="yes">
	
	<cfset var numsteps = ListLen(variables.steps)>
	<cfset var result = "">
	<cfset var ii = 0>
	
	<!---<cfset result = '<p id="cart-steps-#arguments.stepnum#of#numsteps#">(step #arguments.stepnum# of #numsteps#)</p>'>--->
	<cfset result = '#result#<p id="cart-steps-#arguments.stepnum#of#numsteps#">steps: '>
		<cfloop index="ii" from="1" to="#numsteps#" step="1">
			<cfif ii EQ stepnum>
				<cfset result = '#result#<b class="cart-step-curr cart-step-#ii#">#ii#</b> '>
			<cfelseif ii LT stepnum>
				<cfset result = '#result#<a href="#ListGetAt(variables.steps,ii)#" class="cart-step-#ii#">#ii#</a> '>
			<cfelse>
				<cfset result = '#result#<span class="cart-step-#ii#">#ii#</span> '>
			</cfif>
		</cfloop>
	<cfset result = '#result#</p>'>
	
	<cfreturn result>
</cffunction>

</cfsilent><cfoutput>#getStepHTML(attributes.stepnum)#</cfoutput>