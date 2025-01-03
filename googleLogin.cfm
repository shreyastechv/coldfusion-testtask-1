<cfif NOT StructKeyExists(session, "isLoggedIn")>
	<cfset local.environment = createObject( "java", "java.lang.System" )>
	<cfoauth
		type="Google"
		clientid="#local.environment.getenv('ADDRESSBOOK_GOOGLE_CLIENT_ID')#"
		secretkey="#local.environment.getenv('ADDRESSBOOK_GOOGLE_SECRET_KEY')#"
		scope="email"
		result="session.googleData"
	>

	<cfif structKeyExists(session, "googleData")>
		<cfset application.addressbookObject.googleSSOLogin()>
		<cflocation  url="/" addToken="No">
	</cfif>
</cfif>