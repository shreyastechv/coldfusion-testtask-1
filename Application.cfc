<cfcomponent>
	<cfset this.name = "Address Book">
	<cfset this.sessionManagement = true>
	<cfset this.ormEnabled = true>
	<cfset this.ormSettings = {
        cfclocation = "model",
		dbcreate = "update"
	}>
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
		<cfset application.googleClientId = "">
		<cfset application.googleSecretKey = "">
		<!--- <cfset session.statusCodes = StructNew() --->

		<!---<cfquery name="getStatusCodesQuery">
			SELECT statusCode, message
			FROM statusCodes
		</cfquery>
		<cfloop query="getStatusCodesQuery">
			<cfset session.statusCodes["#statusCode#"] = message>
		</cfloop>--->
	</cffunction>

	<cffunction name="onError">
		<cfargument name="exception" required="true">
		<cfargument name="eventName" type="String" required="true">

		<!--- Display an error message if there is a page context --->
		<cfif NOT (arguments.eventName IS "onSessionEnd") OR (arguments.eventName IS "onApplicationEnd")>
			<cfinclude template="error.cfm">
		</cfif>
	</cffunction>
</cfcomponent>
