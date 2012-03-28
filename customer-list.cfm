<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<cf_sebTable isDeletable="!NumOrders">
	<cf_sebColumn dbfield="CustomerName">
	<!--- <cf_sebColumn label="addresses" link="address-list.cfm?customer=">
	<cf_sebColumn label="orders" link="order-list.cfm?customer="> --->
	<cf_sebColumn dbfield="NumOrders" link="order-list.cfm?customer=">
</cf_sebTable>

<cf_layout>