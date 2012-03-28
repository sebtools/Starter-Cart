<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cf_sebForm>
	<cf_sebField name="FirstName">
	<cf_sebField name="LastName">
	<cf_sebField name="Email">
	<cf_sebField name="Phone">
	<cf_sebField type="Submit/Cancel">
</cf_sebForm>

<cfif Action IS "Edit">
	<cf_layout include="order-list.cfm">
	<cf_layout include="address-list.cfm">
</cfif>

<cf_layout>