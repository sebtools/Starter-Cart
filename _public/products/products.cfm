<cf_PageController>

<cf_layout>
<cf_layout showTitle="true">

<ul><cfoutput query="qProducts">
	<li><a href="product.cfm?id=#ProductID#">#ProductName#</a></li></cfoutput>
</ul>

<cf_layout>