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
</cfcomponent>