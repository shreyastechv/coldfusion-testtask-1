<cfcomponent name="addressBook">
    <cffunction name="signUp" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="fullName" type="string">
        <cfargument required="true" name="email" type="string">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">

        <cfset local.hashedPassword = Hash(password, "SHA-256")>
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 0>
        <cfset local.response["message"] = 0>

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
        <cfelse>
            <cfset local.response.statusCode = 1>
            <cfset local.response.message = "Username already exists!">
        </cfif>

        <cfreturn local.response>
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
            <cfset session.isLoggedIn = true>
            <cfset session.userName = getUserDetails.username>
            <cfset session.fullName = getUserDetails.fullname>
            <cfset session.profilePicture = getUserDetails.profilepicture>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="logOut" returnType="struct" returnFormat="json" access="remote">
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 0>
        <cfset local.response["message"] = "">

        <cfset StructClear(session)>
        <cfif NOT StructIsEmpty(session)>
            <cfset local.response.statusCode = 1>
            <cfset local.response.message = "Unable to logout!">
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="getContacts" returnType="query" access="public">
        <cfquery name="local.getContactsQuery">
            SELECT contactid, firstname, lastname, contactpicture, email, phone
            FROM contactDetails
            WHERE _createdBy=<cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
            AND active = 1;
        </cfquery>
        <cfreturn local.getContactsQuery>
    </cffunction>

    <cffunction name="getContactById" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">

        <cfquery name="local.getContactById">
            SELECT contactid, title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone
            FROM contactDetails
            WHERE contactid=<cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_varchar">;
        </cfquery>

        <cfset local.contactDetails = QueryGetRow(local.getContactById, 1)>

        <cfreturn local.contactDetails>
    </cffunction>

    <cffunction name="deleteContact" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">
        <cfset local.response = StructNew()>

        <cfif StructKeyExists(session, "isLoggedIn")>
            <cfquery name="deleteContactQuery">
                UPDATE contactDetails
                SET active = 0
                WHERE contactid=<cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfset local.response["statusCode"] = 0>
        <cfelse>
            <cfset local.response["statusCode"] = 1>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="modifyContacts" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="false" name="contactId" type="string">
        <cfargument required="true" name="title" type="string">
        <cfargument required="true" name="firstName" type="string">
        <cfargument required="true" name="lastName" type="string">
        <cfargument required="true" name="gender" type="string">
        <cfargument required="true" name="dob" type="string">
        <cfargument required="true" name="address" type="string">
        <cfargument required="true" name="street" type="string">
        <cfargument required="true" name="district" type="string">
        <cfargument required="true" name="state" type="string">
        <cfargument required="true" name="country" type="string">
        <cfargument required="true" name="pincode" type="string">
        <cfargument required="true" name="email" type="string">
        <cfargument required="true" name="phone" type="string">
        <cfreturn arguments>
        <cfset local.response = StructNew()>

        <cfif StructKeyExists(session, "isLoggedIn")>
            <cffile action="upload" destination="#expandpath("../assets/contactImages")#" fileField="form.contactImage" nameconflict="MakeUnique">
            <cfset local.contactImage = cffile.serverFile>
            <cfif arguments.contactId IS "">
                <cfquery>
                    INSERT INTO contactDetails
                    (
                        title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone, _createdBy, _updatedBy
                    )
                    VALUES (
                        <cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.gender#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.dob#" cfsqltype="cf_sql_date">,
                        <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.district#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.pincode#" cfsqltype="cf_sql_char">,
                        <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
                    );
                </cfquery>
                <cfset local.response["statusCode"] = 0>
                <cfset local.response["message"] = "Contact Added Successfully">
            <cfelse>
                <cfquery>
                    UPDATE contactDetails
                    SET title = <cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">,
                    firstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">,
                    lastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">,
                    gender = <cfqueryparam value="#arguments.gender#" cfsqltype="cf_sql_varchar">,
                    dob = <cfqueryparam value="#arguments.dob#" cfsqltype="cf_sql_date">,
                    contactImage = <cfqueryparam value="#local.contactImage#" cfsqltype="cf_sql_varchar">,
                    address = <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
                    street = <cfqueryparam value="#arguments.street#" cfsqltype="cf_sql_varchar">,
                    district = <cfqueryparam value="#arguments.district#" cfsqltype="cf_sql_varchar">,
                    state = <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar">,
                    country = <cfqueryparam value="#arguments.country#" cfsqltype="cf_sql_varchar">,
                    pincode = <cfqueryparam value="#arguments.pincode#" cfsqltype="cf_sql_varchar">,
                    email = <cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar">,
                    phone = <cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">,
                    _updatedBy = <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
                    WHERE contactid = <cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfset local.response["statusCode"] = 0>
                <cfset local.response["message"] = "Contact Updated Successfully">
            </cfif>
        <cfelse>
            <cfset local.response["statusCode"] = 1>
        </cfif>

        <cfreturn local.response>
    </cffunction>
</cfcomponent>