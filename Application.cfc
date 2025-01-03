<cfcomponent>
	<cfset this.name = "Address Book">
	<cfset this.sessionManagement = true>
	<cfset this.ormEnabled = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
	<cfset this.dataSource = "addressbookdatasource">

	<cffunction name="onRequest" type="public" returnType="void">
		<cfargument name="requestedPage" type="string">

		<cfif StructKeyExists(session, "isLoggedIn") AND session.isLoggedIn>
			<cfinclude template="home.cfm">
		<cfelse>
			<cfif arguments.requestedPage IS "/home.cfm">
				<cfinclude template="index.cfm">
			<cfelse>
				<cfinclude template="#arguments.requestedPage#">
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="onApplicationStart">
		<cfset application.addressbookObject = CreateObject("component", "components.addressbook")>
	</cffunction>
</cfcomponent>
