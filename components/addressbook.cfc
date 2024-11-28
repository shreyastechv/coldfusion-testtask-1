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

       <cfquery name="checkUser">
            SELECT username
			FROM users
			WHERE username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
        </cfquery>

		<cfquery name="checkEmail">
            SELECT email
			FROM users
			WHERE email = <cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">
        </cfquery>

		<cfif checkEmail.RecordCount>
			<cfset local.response.statusCode = 400>
            <cfset local.response.message = "Email already exists!">
        <cfelseif checkUser.RecordCount>
			<cfset local.response.statusCode = 400>
            <cfset local.response.message = "Username already exists!">
		<cfelse>
            <cffile action="upload" destination="#expandpath("../assets/profilePictures")#" fileField="form.profilePicture" nameconflict="MakeUnique">
            <cfset local.profilePictureName = cffile.serverFile>
            <cfquery name="addUser">
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

        <cfquery name="getUserDetails">
            SELECT username,
				fullname,
				pwd,
				profilepicture
			FROM users
			WHERE username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
        </cfquery>

        <cfif getUserDetails.RecordCount EQ 0>
            <cfset local.response.statusCode = 404>
            <cfset local.response.message = "Username does not exist!">
        <cfelseif getUserDetails.pwd NEQ local.hashedPassword>
            <cfset local.response.statusCode = 401>
            <cfset local.response.message = "Wrong password!">
        <cfelse>
            <cfset session.isLoggedIn = true>
            <cfset session.userName = getUserDetails.username>
            <cfset session.fullName = getUserDetails.fullname>
            <cfset session.profilePicture = "./assets/profilePictures/" & getUserDetails.profilepicture>
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

    <cffunction name="getContacts" returnType="query" access="public">
        <cfquery name="getContactsQuery">
            SELECT contactid,
				firstname,
				lastname,
				contactpicture,
				email,
				phone
			FROM contactDetails
			WHERE _createdBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
				AND active = 1
        </cfquery>
        <cfreturn getContactsQuery>
    </cffunction>

    <cffunction name="getContactById" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">

        <cfquery name="getContactById">
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
			FROM contactDetails
			WHERE contactid = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_varchar">
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
        <cfset local.response = StructNew()>
        <cfset local.contactImage = "demo-contact-image.png">

        <cfif StructKeyExists(session, "isLoggedIn")>
			<cfquery name="getEmailQuery">
				SELECT contactid
				FROM contactDetails
				WHERE _createdBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
					AND email = <cfqueryparam value = "#arguments.editContactEmail#" cfsqltype = "cf_sql_varchar">
					AND active = 1
			</cfquery>
			<cfquery name="getPhoneQuery">
				SELECT contactid
				FROM contactDetails
				WHERE _createdBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
					AND phone = <cfqueryparam value = "#arguments.editContactPhone#" cfsqltype = "cf_sql_varchar">
					AND active = 1
			</cfquery>
			<cfif getEmailQuery.RecordCount NEQ 0 AND getEmailQuery.contactid NEQ arguments.editContactId>
                <cfset local.response["statusCode"] = 409>
                <cfset local.response["message"] = "Email already exists">
			<cfelseif getPhoneQuery.RecordCount NEQ 0 AND getPhoneQuery.contactid NEQ arguments.editContactId>
                <cfset local.response["statusCode"] = 409>
                <cfset local.response["message"] = "Phone number already exists">
			<cfelse>
				<cfif arguments.editContactImage NEQ "">
					<cffile action="upload" destination="#expandpath("../assets/contactImages")#" fileField="form.editContactImage" nameconflict="MakeUnique">
					<cfset local.contactImage = cffile.serverFile>
				</cfif>
				<cfif len(trim(arguments.editContactId)) EQ 0>
					<cfquery name="insertContactsQuery">
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
							_createdBy,
							_updatedBy
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
							<cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
							)
					</cfquery>
					<cfset local.response["statusCode"] = 200>
					<cfset local.response["message"] = "Contact Added Successfully">
				<cfelse>
					<cfquery name="updateContactDetailsQuery">
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
							_updatedBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
						WHERE contactid = <cfqueryparam value = "#arguments.editContactId#" cfsqltype = "cf_sql_varchar">
					</cfquery>
					<cfif arguments.editContactImage NEQ "">
						<cfquery name="updateContactImageQuery">
							UPDATE contactDetails
							SET contactpicture = <cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">
							WHERE contactid = <cfqueryparam value = "#arguments.editContactId#" cfsqltype = "cf_sql_varchar">
						</cfquery>
					</cfif>
					<cfset local.response["statusCode"] = 200>
					<cfset local.response["message"] = "Contact Updated Successfully">
				</cfif>
			</cfif>
        <cfelse>
            <cfset local.response["statusCode"] = 401>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="createExcel" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.spreadsheetName = CreateUUID() & ".xlsx">
		<cfset local.response["data"] = local.spreadsheetName>

        <cfquery name="createExcelQuery">
            SELECT title,
				firstname,
				lastname,
				gender,
				dob,
				address,
				street,
				district,
				STATE,
				country,
				pincode,
				email,
				phone
			FROM contactDetails
			WHERE _createdBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
        </cfquery>

        <cfspreadsheet action="write" filename="../assets/spreadsheets/#local.spreadsheetName#" query="createExcelQuery" sheetname="contacts" overwrite=true>
		<cfreturn local.response>
    </cffunction>

    <cffunction name="createPdf" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.pdfName = CreateUUID() & ".pdf">
		<cfset local.response["data"] = local.pdfName>

        <cfdocument format="pdf" filename="../assets/pdfs/#local.pdfName#" overwrite="true">
            <cfquery name="createPdfQuery">
                SELECT title,
					firstname,
					lastname,
					gender,
					dob,
					contactpicture,
					address,
					street,
					district,
					STATE,
					country,
					pincode,
					email,
					phone
				FROM contactDetails
				WHERE _createdBy = <cfqueryparam value = "#session.userName#" cfsqltype = "cf_sql_varchar">
					AND active = 1
            </cfquery>
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
                            <th>CONTACTPICTURE</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="createPdfQuery">
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
			<cfquery name="checkEmailQuery">
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
					)
			</cfquery>
		</cfif>
		<cfset session.isLoggedIn = true>
		<cfset session.userName = session.googleData.other.email>
		<cfset session.fullName = session.googleData.name>
		<cfset session.profilePicture = session.googleData.other.picture>
		<cflocation url="home.cfm" addToken="no">
	</cffunction>

	<cffunction name="getTaskStatus" returnType="struct" returnFormat="json" access="remote">
		<cfset local.response = StructNew()>
		<cfset local.response["statusCode"] = 404>
		<cfset local.response["taskExists"] = false>

		<cfif StructKeyExists(session, "userName")>
			<cfschedule action="list" mode="application" result="local.tasksQuery">
			<cfset local.taskNames = ValueArray (local.tasksQuery, "task")>
			<cfif QueryKeyExists(local.tasksQuery,"task") AND ArrayContains(local.taskNames, "sendBirthdayWishes-#session.userName#")>
				<cfset local.response["statusCode"] = 200>
				<cfset local.response["taskExists"] = true>
			</cfif>
		</cfif>
		<cfreturn local.response>
	</cffunction>

	<cffunction name="scheduleBdayEmails" returnType="void" access="remote">
		<cfif StructKeyExists(session, "userName")>
			<cfschedule
				action="update"
				task="sendBirthdayWishes-#session.userName#"
				operation="HTTPRequest"
				startDate="#DateFormat(Now(), "mm/dd/yyy")#"
				startTime="8:00 AM"
				mode="application"
				url="http://addressbook.com/components/addressbook.cfc?method=sendBdayEmails&userName=#session.userName#"
				interval="daily"
			>
		</cfif>
	</cffunction>

	<cffunction name="disableBdayEmails" returnType="void" access="remote">
		<cfif StructKeyExists(session, "userName")>
			<cfschedule
				action="delete"
				mode="application"
				task="sendBirthdayWishes-#session.userName#"
			>
		</cfif>
	</cffunction>

	<cffunction name="sendBdayEmails" access="remote" returnType="void">
		<cfargument name="userName" type="string" required="true">
		<cfif cgi.HTTP_USER_AGENT EQ "CFSCHEDULE">
			<cfquery name="getUsersAndDOB">
				SELECT title,
				firstname,
				lastname,
				dob,
				email
				FROM contactDetails
				WHERE _createdBy = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
			</cfquery>

			<cfloop query="getUsersAndDOB">
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

	<!--- <cffunction name="getStatusMessage" access="private" returnType="string">
		<cfargument name="statusCode" type="numeric">
		<cfset local.statusMessage = "">

		<cfif StructKeyExists(session, "statusCodes")>
			<cfset local.statusMessage = session.statusCodes["#arguments.statusCode#"]>
		</cfif>

		<cfreturn local.statusMessage>
	</cffunction> --->
</cfcomponent>
