<cfset qOrders = Application.StarterCart.Orders.getTrends()>

<cf_layout title="Orders">
<cf_layout>

<table cellpadding="5" cellspacing="0">
<tr>
	<th>Number of Orders</th>
	<th>Order Totals (dollars)</th>
</tr>
<tr>
	<td>
		<cfchart format="flash" chartheight="300" chartwidth="300" labelformat="number" tipstyle="mouseOver">
			<cfchartseries type="bar" query="qOrders" itemcolumn="OrderMonthYear" valuecolumn="NumOrders" serieslabel="Order Trend"></cfchartseries>
		</cfchart>
	</td>
	<td>
		<cfchart format="flash" chartheight="300" chartwidth="300" labelformat="number" tipstyle="mouseOver">
			<cfchartseries type="bar" query="qOrders" itemcolumn="OrderMonthYear" valuecolumn="OrdersTotal" serieslabel="Order Trend"></cfchartseries>
		</cfchart>
	</td>
</tr>
</table>

<cf_layout>