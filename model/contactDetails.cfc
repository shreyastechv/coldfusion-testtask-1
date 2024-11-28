<cfcomponent persistent="true" table="contactDetails">
	<cfproperty name="contactid" fieldtype="id" generator="native">
	<cfproperty name="firstName" type="string" column="firstname">
	<cfproperty name="lastName" type="string" column="lastname">
	<cfproperty name="contactPicture" type="string" column="contactpicture">
	<cfproperty name="email" type="string" column="email">
	<cfproperty name="phone" type="string" column="phone">
	<cfproperty name="_createdBy" type="string" column="_createdBy">
	<cfproperty name="active" type="integer" column="active">
</cfcomponent>