<cfcomponent name="addressBook">
    <cffunction name="signUp" returnType="string" returnFormat="json" access="remote">
        <cfargument required="true" name="fullName" type="string">
        <cfargument required="true" name="email" type="string">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">

        <cfset local.hashedPassword = Hash(password, "SHA-256")>

       <cfquery name="checkUser">
            SELECT username
            FROM users
            WHERE username=<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">;
        </cfquery>

        <cfif checkUser.RecordCount EQ 0>
            <cffile action="upload" destination="#expandpath("../assets/profilePictures")#" fileField="form.profilePicture" nameconflict="MakeUnique">
            <cfset local.profilePictureName = cffile.serverFile>
            <cfquery name="addUser">
                INSERT INTO users
                (fullname, email, username, pwd, profilePicture)
                VALUES (
                    <cfqueryparam value="#arguments.fullName#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#local.hashedPassword#" cfsqltype="cf_sql_char">,
                    <cfqueryparam value="#local.profilePictureName#" cfsqltype="cf_sql_varchar">
                );
            </cfquery>
            <cfset local.message = "Account created successfully. Login to continue.">
        <cfelse>
            <cfset local.message = "Username already taken.">
        </cfif>

        <cfreturn local.message>
    </cffunction>

    <cffunction name="logIn" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">

        <cfset local.hashedPassword = Hash(password, "SHA-256")>
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 0>
        <cfset local.response["message"] = "">

        <cfquery name="getUserDetails">
            SELECT username, fullname, pwd, profilepicture
            FROM users
            WHERE username=<cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">;
        </cfquery>

        <cfif getUserDetails.RecordCount EQ 0>
            <cfset local.response.statusCode = 1>
            <cfset local.response.message = "Username does not exist!">
        <cfelseif getUserDetails.pwd NEQ local.hashedPassword>
            <cfset local.response.statusCode = 2>
            <cfset local.response.message = "Wrong password!">
        <cfelse>
            <cfset session.userName = getUserDetails.username>
            <cfset session.fullName = getUserDetails.fullname>
            <cfset session.profilePicture = getUserDetails.profilepicture>
        </cfif>

        <cfreturn local.response>
    </cffunction>
</cfcomponent>