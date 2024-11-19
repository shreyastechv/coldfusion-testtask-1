<cfcomponent>
    <cfset this.name = "Address Book">
    <cfset this.sessionManagement = true>
    <cfset this.dataSource = "addressbookdatasource">

	<cffunction name="onRequest" type="public" returnType="void">
		<cfargument name="requestedPage" type="string">

		<cfif StructKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
			<cfinclude template="home.cfm">
		<cfelse>
			<cfif requestedPage IS "/shreyas/cf-testtask/home.cfm">
				<cfinclude template="index.cfm">
			<cfelse>
				<cfinclude template="#requestedPage#">
			</cfif>
		</cfif>
	</cffunction>
</cfcomponent>
