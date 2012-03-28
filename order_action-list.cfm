<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cf_sebTable label="Order History" labelSuffix="" isAddable="false" isEditable="false" isDeletable="false">
	<cf_sebColumn dbfield="DateTimeTaken" type="datetime" DefaultSort="DESC">
	<cf_sebColumn dbfield="OrderID">
	<cf_sebColumn dbfield="ActionID">
	<cf_sebColumn link="order_action-edit.cfm?id=" label="view" show="hasExtraInfo">
</cf_sebTable>

<cf_layout>