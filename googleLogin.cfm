<cfif NOT StructKeyExists(session, "isLoggedIn")>
	<cfoauth
		type="Google"
		clientid="#application.googleClientId#"
		secretkey="#application.googleSecretKey#"
		result="output"
	>
	
	<cfif structKeyExists(variables, "output")>
		<cfset session.googleData = output>
		<cflocation url="index.cfm" addtoken="no">
	</cfif>
</cfif>