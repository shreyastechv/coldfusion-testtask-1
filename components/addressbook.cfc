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
        <cfquery name="getContactsQuery">
            SELECT contactid, firstname, lastname, contactpicture, email, phone
            FROM contactDetails
            WHERE _createdBy=<cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
            AND active = 1;
        </cfquery>
        <cfreturn getContactsQuery>
    </cffunction>

    <cffunction name="getContactById" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">

        <cfquery name="getContactById">
            SELECT contactid, title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone
            FROM contactDetails
            WHERE contactid=<cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_varchar">;
        </cfquery>

        <cfset local.contactDetails = QueryGetRow(getContactById, 1)>

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
        <cfargument required="false" name="editContactId" type="string">
        <cfargument required="true" name="editContactTitle" type="string">
        <cfargument required="true" name="editContactFirstName" type="string">
        <cfargument required="true" name="editContactLastName" type="string">
        <cfargument required="true" name="editContactGender" type="string">
        <cfargument required="true" name="editContactDOB" type="string">
        <cfargument required="true" name="editContactImage" type="string">
        <cfargument required="true" name="editContactAddress" type="string">
        <cfargument required="true" name="editContactStreet" type="string">
        <cfargument required="true" name="editContactDistrict" type="string">
        <cfargument required="true" name="editContactState" type="string">
        <cfargument required="true" name="editContactCountry" type="string">
        <cfargument required="true" name="editContactPincode" type="string">
        <cfargument required="true" name="editContactEmail" type="string">
        <cfargument required="true" name="editContactPhone" type="string">
        <cfset local.response = StructNew()>
        <cfset local.contactImage = "demo-contact-image.png">

        <cfif StructKeyExists(session, "isLoggedIn")>
            <cfif arguments.editContactImage NEQ "">
                <cffile action="upload" destination="#expandpath("../assets/contactImages")#" fileField="form.editContactImage" nameconflict="MakeUnique">
                <cfset local.contactImage = cffile.serverFile>
            </cfif>
            <cfif len(trim(arguments.editContactId)) EQ 0>
                <cfquery name="insertContactsQuery">
                    INSERT INTO contactDetails
                    (
                        title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone, _createdBy, _updatedBy
                    )
                    VALUES (
                        <cfqueryparam value="#arguments.editContactTitle#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactFirstName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactLastName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactGender#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactDOB#" cfsqltype="cf_sql_date">,
                        <cfqueryparam value="#local.contactImage#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactAddress#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactStreet#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactDistrict#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactState#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactCountry#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactPincode#" cfsqltype="cf_sql_char">,
                        <cfqueryparam value="#arguments.editContactEmail#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.editContactPhone#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
                    );
                </cfquery>
                <cfset local.response["statusCode"] = 0>
                <cfset local.response["message"] = "Contact Added Successfully">
            <cfelse>
                <cfquery name="updateContactDetailsQuery">
                    UPDATE contactDetails
                    SET title = <cfqueryparam value="#arguments.editContactTitle#" cfsqltype="cf_sql_varchar">,
                    firstName = <cfqueryparam value="#arguments.editContactFirstName#" cfsqltype="cf_sql_varchar">,
                    lastName = <cfqueryparam value="#arguments.editContactLastName#" cfsqltype="cf_sql_varchar">,
                    gender = <cfqueryparam value="#arguments.editContactGender#" cfsqltype="cf_sql_varchar">,
                    dob = <cfqueryparam value="#arguments.editContactDOB#" cfsqltype="cf_sql_date">,
                    address = <cfqueryparam value="#arguments.editContactAddress#" cfsqltype="cf_sql_varchar">,
                    street = <cfqueryparam value="#arguments.editContactStreet#" cfsqltype="cf_sql_varchar">,
                    district = <cfqueryparam value="#arguments.editContactDistrict#" cfsqltype="cf_sql_varchar">,
                    state = <cfqueryparam value="#arguments.editContactState#" cfsqltype="cf_sql_varchar">,
                    country = <cfqueryparam value="#arguments.editContactCountry#" cfsqltype="cf_sql_varchar">,
                    pincode = <cfqueryparam value="#arguments.editContactPincode#" cfsqltype="cf_sql_varchar">,
                    email = <cfqueryparam value="#arguments.editContactEmail#" cfsqltype="cf_sql_varchar">,
                    phone = <cfqueryparam value="#arguments.editContactPhone#" cfsqltype="cf_sql_varchar">,
                    _updatedBy = <cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
                    WHERE contactid = <cfqueryparam value="#arguments.editContactId#" cfsqltype="cf_sql_varchar">;
                </cfquery>
                <cfif arguments.editContactImage NEQ "">
                    <cfquery name="updateContactImageQuery">
                        UPDATE contactDetails
                        SET contactpicture = <cfqueryparam value="#local.contactImage#" cfsqltype="cf_sql_varchar">
                        WHERE contactid = <cfqueryparam value="#arguments.editContactId#" cfsqltype="cf_sql_varchar">;
                    </cfquery>
                </cfif>
                <cfset local.response["statusCode"] = 0>
                <cfset local.response["message"] = "Contact Updated Successfully">
            </cfif>
        <cfelse>
            <cfset local.response["statusCode"] = 1>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="createExcel" returnType="void" access="remote">
        <cfquery name="createExcelQuery">
            SELECT contactid, title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone, _createdBy, _updatedBy
            FROM contactDetails
            WHERE _createdBy=<cfqueryparam value="#session.userName#" cfsqltype="cf_sql_varchar">
            AND active = 1;
        </cfquery>
        <cfspreadsheet action="write" filename="../assets/contacts.xlsx" query="createExcelQuery" sheetname="contacts" overwrite=true>
    </cffunction>

    <cffunction name="createPdf" returnType="void" access="remote">
        <cfdocument format="pdf" filename="../assets/contacts.pdf" overwrite="true">
            <cfoutput>#session.contactsTableSection#</cfoutput>
        </cfdocument>
    </cffunction>
</cfcomponent>