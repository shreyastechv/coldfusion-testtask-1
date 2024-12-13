<cfif NOT StructKeyExists(session, "isLoggedIn")>
	<cfoauth
		type="Google"
		clientid="#application.googleClientId#"
		secretkey="#application.googleSecretKey#"
		scope="email"
		result="session.googleData"
	>

	<cfif structKeyExists(session, "googleData")>
		<cfset application.addressbookObject.googleSSOLogin()>
		<cflocation  url="/" addToken="No">
	</cfif>
</cfif>