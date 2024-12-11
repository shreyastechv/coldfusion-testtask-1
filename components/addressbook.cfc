<cfcomponent name="addressBook">
    <cffunction name="signUp" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="fullName" type="string">
        <cfargument required="true" name="email" type="string">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">

        <cfset local.hashedPassword = Hash(password, "SHA-256")>
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 200>
        <cfset local.response["message"] = "">

       <cfquery name="local.checkUsernameAndEmail">
            SELECT username
			FROM users
			WHERE username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
				OR email = <cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">
        </cfquery>

		<cfif local.checkUsernameAndEmail.RecordCount>
			<cfset local.response.statusCode = 400>
            <cfset local.response.message = "Email or Username already exists!">
		<cfelse>
            <cffile action="upload" destination="#expandpath("../assets/profilePictures")#" fileField="form.profilePicture" nameconflict="MakeUnique">
            <cfset local.profilePictureName = cffile.serverFile>
            <cfquery name="local.addUser">
                INSERT INTO users (
					fullname,
					email,
					username,
					pwd,
					profilePicture
				)
				VALUES (
					<cfqueryparam value = "#arguments.fullName#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#local.hashedPassword#" cfsqltype = "cf_sql_char">,
					<cfqueryparam value = "#local.profilePictureName#" cfsqltype = "cf_sql_varchar">
				)
            </cfquery>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="logIn" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">

        <cfset local.hashedPassword = Hash(password, "SHA-256")>
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 200>
        <cfset local.response["message"] = "">

        <cfquery name="local.getUserDetails">
            SELECT userid,
				username,
				fullname,
				profilepicture
			FROM users
			WHERE username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
				AND pwd = <cfqueryparam value = "#local.hashedPassword#" cfsqltype = "cf_sql_varchar">
        </cfquery>

        <cfif local.getUserDetails.RecordCount EQ 0>
            <cfset local.response.statusCode = 401>
            <cfset local.response.message = "Wrong username or password!">
        <cfelse>
            <cfset session.isLoggedIn = true>
            <cfset session.userId = local.getUserDetails.userId>
            <cfset session.fullName = local.getUserDetails.fullname>
            <cfset session.profilePicture = "./assets/profilePictures/" & local.getUserDetails.profilepicture>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="logOut" returnType="struct" returnFormat="json" access="remote">
        <cfset local.response = StructNew()>
        <cfset local.response["statusCode"] = 200>
        <cfset local.response["message"] = "">

        <cfset StructClear(session)>
        <cfif NOT StructIsEmpty(session)>
            <cfset local.response.statusCode = 401>
            <cfset local.response.message = "Unable to logout!">
        </cfif>

        <cfreturn local.response>
    </cffunction>

	<cffunction name="getContacts" returnType="query" returnFormat="json" access="remote">
		<cfset local.contactDetails = ArrayNew(1)>
		<cfset local.columnList = [
			"contactid",
			"firstname",
			"lastname",
			"contactpicture",
			"email",
			"phone"
		]>

        <cfquery name="local.getContactRolesQuery">
            SELECT #ArrayToList(local.columnList)#
            FROM contactDetails
            WHERE createdBy = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_varchar">
            AND active = 1;
        </cfquery>


        <cfreturn local.getContactRolesQuery>
    </cffunction>

    <cffunction name="getContactById" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">

		<cfquery name="local.getContactByIdQuery">
            SELECT contactid,
				title,
				firstname,
				lastname,
				gender,
				dob,
				contactpicture,
				address,
				street,
				district,
				state,
				country,
				pincode,
				email,
				phone
			FROM contactDetails AS cd
			LEFT JOIN contactRoles AS cr
			ON
			JOIN
			WHERE contactid = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_varchar">
        </cfquery>
		<cfset local.result = {}>
		<cfloop query ="local.getContactByIdQuery">
		  <cfset local.result["contactid"] = local.getContactByIdQuery.contactid>

		</cfloop>
    </cffunction>

    <cffunction name="deleteContact" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">
        <cfset local.response = StructNew()>

        <cfif StructKeyExists(session, "isLoggedIn")>
            <cfquery name="local.deleteRoleQuery">
                DELETE FROM contactRoles
				WHERE contactId = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_varchar">
            </cfquery>
			<cfquery name="local.deleteContactQuery">
            	UPDATE contactDetails
				SET active = 0
				WHERE contactid = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_varchar">
            </cfquery>

            <cfset local.response["statusCode"] = 200>
        <cfelse>
            <cfset local.response["statusCode"] = 401>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="modifyContacts" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="editContactId" type="string">
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
        <cfargument required="true" name="editContactRole" type="string">
        <cfset local.response = StructNew()>
        <cfset local.contactImage = "demo-contact-image.png">

        <cfif StructKeyExists(session, "isLoggedIn")>
			<cfquery name="local.getEmailPhoneQuery">
				SELECT contactid
				FROM contactDetails
				WHERE createdBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					AND (
						email = <cfqueryparam value = "#arguments.editContactEmail#" cfsqltype = "cf_sql_varchar">
						OR phone = <cfqueryparam value = "#arguments.editContactPhone#" cfsqltype = "cf_sql_varchar">
					)
					AND active = 1
			</cfquery>
			<cfif local.getEmailPhoneQuery.RecordCount AND local.getEmailPhoneQuery.contactid NEQ arguments.editContactId>
                <cfset local.response["statusCode"] = 409>
                <cfset local.response["message"] = "Email id or Phone number already exists">
			<cfelse>
				<cfif arguments.editContactImage NEQ "">
					<cffile action="upload" destination="#expandpath("../assets/contactImages")#" fileField="form.editContactImage" nameconflict="MakeUnique">
					<cfset local.contactImage = cffile.serverFile>
				</cfif>
				<cfif len(trim(arguments.editContactId)) EQ 0>
					<cfquery name="local.insertContactsQuery" result="local.insertContactsResult">
						INSERT INTO contactDetails (
							title,
							firstname,
							lastname,
							gender,
							dob,
							contactpicture,
							address,
							street,
							district,
							state,
							country,
							pincode,
							email,
							phone,
							createdBy
						)
						VALUES (
							<cfqueryparam value = "#arguments.editContactTitle#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactFirstName#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactLastName#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactGender#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactDOB#" cfsqltype = "cf_sql_date">,
							<cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactAddress#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactStreet#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactDistrict#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactState#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactCountry#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactPincode#" cfsqltype = "cf_sql_char">,
							<cfqueryparam value = "#arguments.editContactEmail#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.editContactPhone#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
						);
					</cfquery>
					<cfloop list="#arguments.editContactRole#" item="local.userRole">
						<cfquery name="local.addRolesQuery">
							INSERT INTO contactRoles(
								contactId,
								roleId
							)
							VALUES (
								<cfqueryparam value = "#insertContactsResult.GENERATEDKEY#" cfsqltype = "cf_sql_varchar">,
								<cfqueryparam value = "#local.userRole#" cfsqltype = "cf_sql_integer">
							)
						</cfquery>
					</cfloop>
					<cfset local.response["statusCode"] = 200>
					<cfset local.response["message"] = "Contact Added Successfully">
				<cfelse>
					<cfquery name="local.updateContactDetailsQuery">
						UPDATE contactDetails
						SET title = <cfqueryparam value = "#arguments.editContactTitle#" cfsqltype = "cf_sql_varchar">,
							firstName = <cfqueryparam value = "#arguments.editContactFirstName#" cfsqltype = "cf_sql_varchar">,
							lastName = <cfqueryparam value = "#arguments.editContactLastName#" cfsqltype = "cf_sql_varchar">,
							gender = <cfqueryparam value = "#arguments.editContactGender#" cfsqltype = "cf_sql_varchar">,
							dob = <cfqueryparam value = "#arguments.editContactDOB#" cfsqltype = "cf_sql_date">,
							address = <cfqueryparam value = "#arguments.editContactAddress#" cfsqltype = "cf_sql_varchar">,
							street = <cfqueryparam value = "#arguments.editContactStreet#" cfsqltype = "cf_sql_varchar">,
							district = <cfqueryparam value = "#arguments.editContactDistrict#" cfsqltype = "cf_sql_varchar">,
							STATE = <cfqueryparam value = "#arguments.editContactState#" cfsqltype = "cf_sql_varchar">,
							country = <cfqueryparam value = "#arguments.editContactCountry#" cfsqltype = "cf_sql_varchar">,
							pincode = <cfqueryparam value = "#arguments.editContactPincode#" cfsqltype = "cf_sql_varchar">,
							email = <cfqueryparam value = "#arguments.editContactEmail#" cfsqltype = "cf_sql_varchar">,
							phone = <cfqueryparam value = "#arguments.editContactPhone#" cfsqltype = "cf_sql_varchar">,
							<cfif arguments.editContactImage NEQ "">
								contactpicture = <cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
							</cfif>
							updatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
						WHERE contactid = <cfqueryparam value = "#arguments.editContactId#" cfsqltype = "cf_sql_varchar">
					</cfquery>
					<cfquery name="local.deleteRoleQuery">
						DELETE FROM contactRoles
						WHERE contactId = <cfqueryparam value = "#arguments.editContactId#" cfsqltype = "cf_sql_varchar">
					</cfquery>
					<cfloop list="#arguments.editContactRole#" item="local.userRole">
						<cfquery name="local.addRolesQuery">
							INSERT INTO contactRoles(
								contactId,
								roleId
							)
							VALUES (
								<cfqueryparam value = "#arguments.editContactId#" cfsqltype = "cf_sql_varchar">,
								<cfqueryparam value = "#local.userRole#" cfsqltype = "cf_sql_integer">
							)
						</cfquery>
					</cfloop>
					<cfset local.response["statusCode"] = 200>
					<cfset local.response["message"] = "Contact Updated Successfully">
				</cfif>
			</cfif>
        <cfelse>
            <cfset local.response["statusCode"] = 401>
        </cfif>

        <cfreturn local.response>
    </cffunction>

	<cffunction  name="getRoleDetails" returnType="query" access="public">
		<cfquery name="local.getContactRoleDetailsQuery">
			SELECT roleId, roleName
			FROM roleDetails
		</cfquery>

		<cfreturn local.getContactRoleDetailsQuery>
	</cffunction>

	<cffunction  name="getContactRolesAsArray" returnType="array" access="private">
		<cfset local.contacts = entityLoad("contactDetailsORM", {createdBy = session.userId, active = 1})>
		<cfset local.contactsQuery = EntityToQuery(local.contacts)>
		<cfset local.contactRoles = ArrayNew(1)>
		<cfloop query="local.contactsQuery">
			<cfquery name="local.getContactRolesQuery">
				SELECT d.roleName
				FROM contactRoles AS r
				RIGHT JOIN roleDetails AS d
				ON r.roleId = d.roleId
				WHERE contactId = <cfqueryparam value = "#local.contactsQuery.contactId#" cfsqltype = "cf_sql_varchar">
			</cfquery>
			<cfset ArrayAppend(local.contactRoles, ArrayToList(valueArray(local.getContactRolesQuery, "roleName")))>
		</cfloop>

		<cfreturn local.contactRoles>
	</cffunction>

    <cffunction name="createExcel" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.timestamp = DateFormat(Now(), "yyyy-mm-dd") & "-" & TimeFormat(Now(), "HH-mm-ss")>
		<cfset local.spreadsheetName = "#session.fullName#-#local.timestamp#.xlsx">
		<cfset local.response["data"] = local.spreadsheetName>
		<cfset local.contacts = entityLoad("contactDetailsORM", {createdBy = session.userId, active = 1})>
		<cfset local.createExcelQuery = EntityToQuery(local.contacts)>
		<cfset local.contactRoles = getContactRolesAsArray()>
		<cfset QueryAddColumn(local.createExcelQuery, "roles", local.contactRoles)>

        <cfspreadsheet action="write" filename="../assets/spreadsheets/#local.spreadsheetName#" query="local.createExcelQuery" sheetname="contacts" overwrite=true>
		<cfreturn local.response>
    </cffunction>

    <cffunction name="createPdf" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.timestamp = DateFormat(Now(), "yyyy-mm-dd") & "-" & TimeFormat(Now(), "HH-mm-ss")>
		<cfset local.pdfName = "#session.fullName#-#local.timestamp#.pdf">
		<cfset local.response["data"] = local.pdfName>
		<cfset local.contacts = entityLoad("contactDetailsORM", {createdBy = session.userId, active = 1})>
		<cfset local.createPdfQuery = EntityToQuery(local.contacts)>
		<cfset local.contactRoles = getContactRolesAsArray()>
		<cfset QueryAddColumn(local.createPdfQuery, "roles", local.contactRoles)>

        <cfdocument format="pdf" filename="../assets/pdfs/#local.pdfName#" overwrite="true">
            <cfoutput>
                <table border="1" cellpadding="0" cellspacing="0">
                    <thead>
                        <tr>
                            <th>TITLE</th>
                            <th>FIRSTNAME</th>
                            <th>LASTNAME</th>
                            <th>GENDER</th>
                            <th>DOB</th>
                            <th>ADDRESS</th>
                            <th>STREET</th>
                            <th>DISTRICT</th>
                            <th>STATE</th>
                            <th>COUNTRY</th>
                            <th>PINCODE</th>
                            <th>EMAIL ID</th>
                            <th>PHONE NUMBER</th>
							<th>ROLES</th>
                            <th>CONTACTPICTURE</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="local.createPdfQuery">
                            <tr>
                                <td>#title#</td>
                                <td>#firstname#</td>
                                <td>#lastname#</td>
                                <td>#gender#</td>
                                <td>#dob#</td>
                                <td>#address#</td>
                                <td>#street#</td>
                                <td>#district#</td>
                                <td>#state#</td>
                                <td>#country#</td>
                                <td>#pincode#</td>
                                <td>#email#</td>
                                <td>#phone#</td>
                                <td>#roles#</td>
                                <td>
                                    <img class="img" height="50" src="../assets/contactImages/#contactpicture#" alt="Contact Image">
                                </td>
                            </tr>
                        </cfloop>
                    </tbody>
                </table>
            </cfoutput>
        </cfdocument>

		<cfreturn local.response>
    </cffunction>

	<cffunction name="googleSSOLogin" returnType="void" access="public">
		<cfquery name="checkEmailQuery">
			SELECT email
			FROM users
			WHERE email = <cfqueryparam value = "#session.googleData.other.email#" cfsqltype = "cf_sql_varchar">
		</cfquery>
		<cfif checkEmailQuery.RecordCount EQ 0>
			<cfquery name="insertUserDataQuery">
				INSERT INTO users (
					fullname,
					email,
					username,
					profilePicture
				)
				VALUES (
					<cfqueryparam value = "#session.googleData.name#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#session.googleData.other.email#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#session.googleData.other.email#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#session.googleData.other.picture#" cfsqltype = "cf_sql_varchar">
				);
			</cfquery>
		</cfif>
		<cfquery name="local.getUserIdQuery">
			SELECT userid
			FROM users
			WHERE email = <cfqueryparam value = "#session.googleData.other.email#" cfsqltype = "cf_sql_varchar">
		</cfquery>
		<cfset session.isLoggedIn = true>
		<cfset session.userId = local.getUserIdQuery.userid>
		<cfset session.fullName = session.googleData.name>
		<cfset session.profilePicture = session.googleData.other.picture>
		<cflocation url="/" addToken="no">
	</cffunction>

	<cffunction name="getTaskStatus" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.response["statusCode"] = 404>
		<cfset local.response["taskExists"] = false>

		<cfif StructKeyExists(session, "userId")>
			<cfschedule action="list" mode="application" result="local.tasksQuery">
			<cfset local.taskNames = ValueArray(local.tasksQuery, "task")>
			<cfif QueryKeyExists(local.tasksQuery,"task") AND ArrayContains(local.taskNames, "sendBirthdayWishes-#session.userId#")>
				<cfset local.response["statusCode"] = 200>
				<cfset local.response["taskExists"] = true>
			</cfif>
		</cfif>
		<cfreturn local.response>
	</cffunction>

	<cffunction name="toggleBdayEmailSchedule" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.taskExists = getTaskStatus().taskExists>

		<cfif StructKeyExists(session, "userId")>
			<cfif local.taskExists>
				<cfschedule
					action="delete"
					mode="application"
					task="sendBirthdayWishes-#session.userId#"
				>
			<cfelse>
				<cfschedule
					action="update"
					task="sendBirthdayWishes-#session.userId#"
					operation="HTTPRequest"
					startDate="#DateFormat(Now(), "mm/dd/yyy")#"
					startTime="8:00 AM"
					mode="application"
					url="http://addressbook.com/components/addressbook.cfc?method=sendBdayEmails&userId=#session.userId#"
					interval="daily"
				>
			</cfif>

			<cfset local.response["taskcurrentlyExists"] = getTaskStatus().taskExists>
		</cfif>

		<cfreturn local.response>
	</cffunction>

	<cffunction name="sendBdayEmails" access="remote" returnType="void">
		<cfargument name="userId" type="string" required="true">
		<cfif cgi.HTTP_USER_AGENT EQ "CFSCHEDULE">
			<cfquery name="local.getUsersAndDOB">
				SELECT title,
				firstname,
				lastname,
				dob,
				email
				FROM contactDetails
				WHERE createdBy = <cfqueryparam value = "#arguments.userId#" cfsqltype = "cf_sql_varchar">
			</cfquery>

			<cfloop query="local.getUsersAndDOB">
				<cfif Day(dob) EQ Day(Now()) AND Month(dob) EQ Month(Now())>
					<cfmail from="test@test.com" to="#email#" subject="Birthday Wishes">
						Good Morning #title# #firstname# #lastname#,
						We are wishing you a happy birthday and many more happy returns of the day.
					</cfmail>
				</cfif>
			</cfloop>
		<cfelse>
			<cfheader statusCode="403" statusText="Forbidden">
			<cfoutput>Access denied.</cfoutput>
			<cfabort>
		</cfif>
	</cffunction>
</cfcomponent>
