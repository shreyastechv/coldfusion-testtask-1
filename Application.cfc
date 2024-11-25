<cfcomponent>
	<cfset this.name = "Address Book">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0, 1, 0, 0)>
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

	<cffunction name="onError">
		<cfargument name="exception" required="true">
		<cfargument name="eventName" type="String" required="true">

		<!--- Log all errors --->
		<cflog file="#this.name#" type="error" text="Event Name: #arguments.eventName#" >
		<cflog file="#this.name#" type="error" text="Message: #arguments.exception.message#">
		<cflog file="#this.name#" type="error" text="Root Cause Message: #arguments.exception.rootcause.message#">

		<!--- Display an error message if there is a page context --->
		<cfif NOT (arguments.eventName IS "onSessionEnd") OR (arguments.eventName IS "onApplicationEnd")>
			<cfinclude template="error.cfm">
		</cfif>
	</cffunction>
</cfcomponent>
