<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cf_sebForm>
	<cf_sebField name="CountryName">
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

<cfif Action IS "Edit">
	<cf_layout include="state_province-list.cfm">
</cfif>

<cf_layout>