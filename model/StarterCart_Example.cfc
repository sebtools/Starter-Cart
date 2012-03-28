<cfcomponent extends="StarterCart">

<cffunction name="customxml">
<tables>
	<table name="prodProducts">
		<field
			name="ProductImage"
			label="Image"
			type="image"
			folder="images"
			MaxWidth="400"
			MaxHeight="400"
		/>
		<field
			name="ProductThumb"
			label="Thumbnail"
			type="thumb"
			folder="thumbs"
			original="ProductImage"
			MaxWidth="80"
			MaxHeight="80"
		/>
	</table>
</tables>
</cffunction>

</cfcomponent>