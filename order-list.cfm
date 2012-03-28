<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<p><a href="order-chart.cfm">See Chart</a></p>

<cf_sebTable isEditable="false" isDeletable="false" isAddable="false">
	<cf_sebColumn dbfield="DatePlaced" type="datetime" defaultSort="DESC">
	<cf_sebColumn dbfield="CustomerID">
	<cf_sebColumn dbfield="DiscountID">
	<!---<cf_sebColumn dbfield="ShipperID">--->
	<cf_sebColumn dbfield="Status">
	<cf_sebColumn label="view" link="order-edit.cfm?id=">
</cf_sebTable>

<cf_layout>