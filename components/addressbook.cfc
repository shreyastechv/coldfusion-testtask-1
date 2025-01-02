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
            SELECT
				username
			FROM
				users
			WHERE
				username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
				OR email = <cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">
        </cfquery>

		<cfif local.checkUsernameAndEmail.RecordCount>
			<cfset local.response.statusCode = 400>
            <cfset local.response.message = "Email or Username already exists!">
		<cfelse>
            <cffile action="upload" destination="#expandpath("../assets/profilePictures")#" fileField="form.profilePicture" nameconflict="MakeUnique">
            <cfset local.profilePictureName = cffile.serverFile>
            <cfquery name="local.addUser">
                INSERT INTO
					users (
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
            SELECT
				userid,
				username,
				fullname,
				profilepicture
			FROM
				users
			WHERE
				username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
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

	<cffunction name="googleSSOLogin" returnType="void" access="public">
		<cfquery name="local.checkEmailQuery">
			SELECT
				userid
			FROM
				users
			WHERE
				email = <cfqueryparam value = "#session.googleData.other.email#" cfsqltype = "cf_sql_varchar">
		</cfquery>
		<cfif local.checkEmailQuery.RecordCount EQ 0>
			<cfquery name="insertUserDataQuery" result="local.insertUserDataResult">
				INSERT INTO
					users (
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
			<cfset session.userId = local.insertUserDataResult.GENERATEDKEY>
		<cfelse>
			<cfset session.userId = local.checkEmailQuery.userid>
		</cfif>
		<cfset session.isLoggedIn = true>
		<cfset session.fullName = session.googleData.name>
		<cfset session.profilePicture = session.googleData.other.picture>
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
        <cfquery name="local.getContactsQuery">
            SELECT
				contactid,
				firstname,
				lastname,
				contactpicture,
				email,
				phone
            FROM
				contactDetails
            WHERE
				createdBy = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
            	AND active = 1;
        </cfquery>

        <cfreturn local.getContactsQuery>
    </cffunction>

	<cffunction name="getFullContacts" returnType="query" returnFormat="json" access="remote">
		<cfargument required="false" name="usage" type="string" default="">
        <cfquery name="local.getFullContactsQuery">
            SELECT
				<cfif arguments.usage EQ "excelTempate">
					TOP 0
				</cfif>
				cd.title,
				cd.firstname,
				cd.lastname,
				cd.gender,
				cd.dob,
				cd.address,
				cd.street,
				cd.district,
				cd.state,
				cd.country,
				cd.pincode,
				cd.email,
				cd.phone,
				STRING_AGG(rd.roleName, ',') AS roles,
				cd.contactpicture
			FROM
				contactDetails cd
				LEFT JOIN contactRoles cr ON cd.contactid = cr.contactId
				LEFT JOIN roleDetails rd ON cr.roleId = rd.roleId
			WHERE
				cd.createdBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
				AND cd.active = 1
				AND cr.active = 1
			GROUP BY
				cd.title,
				cd.firstname,
				cd.lastname,
				cd.gender,
				cd.dob,
				cd.contactpicture,
				cd.address,
				cd.street,
				cd.district,
				cd.state,
				cd.country,
				cd.pincode,
				cd.email,
				cd.phone
        </cfquery>

        <cfreturn local.getFullContactsQuery>
    </cffunction>

    <cffunction name="getContactById" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">
		<cfset local.result = {}>

		<cfquery name="local.getContactByIdQuery">
			SELECT
				cd.contactid,
				cd.title,
				cd.firstname,
				cd.lastname,
				cd.gender,
				cd.dob,
				cd.contactpicture,
				cd.address,
				cd.street,
				cd.district,
				cd.state,
				cd.country,
				cd.pincode,
				cd.email,
				cd.phone,
				ISNULL(STRING_AGG(CONVERT(VARCHAR(36), cr.roleId), ','), '') AS roleIds,
				ISNULL(STRING_AGG(rd.roleName, ','), '') AS roleNames
			FROM
				contactDetails cd
				LEFT JOIN contactRoles cr ON cd.contactid = cr.contactId AND cr.active = 1
				LEFT JOIN roleDetails rd ON cr.roleId = rd.roleId
			WHERE
				cd.contactid = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">
			GROUP BY
				cd.contactid,
				cd.title,
				cd.firstname,
				cd.lastname,
				cd.gender,
				cd.dob,
				cd.contactpicture,
				cd.address,
				cd.street,
				cd.district,
				cd.state,
				cd.country,
				cd.pincode,
				cd.email,
				cd.phone
        </cfquery>
		<cfloop query ="local.getContactByIdQuery">
			<cfset local.result = {
				"contactid" = local.getContactByIdQuery.contactid,
				"title" = local.getContactByIdQuery.title,
				"firstname" = local.getContactByIdQuery.firstname,
				"lastname" = local.getContactByIdQuery.lastname,
				"gender" = local.getContactByIdQuery.gender,
				"dob" = local.getContactByIdQuery.dob,
				"contactPicture" = local.getContactByIdQuery.contactpicture,
				"address" = local.getContactByIdQuery.address,
				"street" = local.getContactByIdQuery.street,
				"district" = local.getContactByIdQuery.district,
				"state" = local.getContactByIdQuery.state,
				"country" = local.getContactByIdQuery.country,
				"pincode" = local.getContactByIdQuery.pincode,
				"email" = local.getContactByIdQuery.email,
				"phone" = local.getContactByIdQuery.phone,
				"roleIds" = ListToArray(local.getContactByIdQuery.roleIds),
				"roleNames" = ListToArray(local.getContactByIdQuery.roleNames)
			}>
		</cfloop>

		<cfreturn local.result>
    </cffunction>

    <cffunction name="deleteContact" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">
        <cfset local.response = StructNew()>

        <cfif StructKeyExists(session, "isLoggedIn")>
			<cfquery name="local.deleteContactQuery">
            	BEGIN TRANSACTION;

				-- Delete from contactRoles
				UPDATE
					contactRoles
				SET
					active = 0,
					deletedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_varchar">
				WHERE
					contactId = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">;

				-- Update contactDetails
				UPDATE
					contactDetails
				SET
					active = 0,
					deletedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_varchar">
				WHERE
					contactId = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">;

				COMMIT;
            </cfquery>

            <cfset local.response["statusCode"] = 200>
        <cfelse>
            <cfset local.response["statusCode"] = 401>
        </cfif>

        <cfreturn local.response>
    </cffunction>

    <cffunction name="modifyContacts" returnType="struct" returnFormat="json" access="remote">
        <cfargument required="true" name="contactId" type="string">
        <cfargument required="true" name="contactTitle" type="string">
        <cfargument required="true" name="contactFirstName" type="string">
        <cfargument required="true" name="contactLastName" type="string">
        <cfargument required="true" name="contactGender" type="string">
        <cfargument required="true" name="contactDOB" type="string">
        <cfargument required="true" name="contactImage" type="string">
        <cfargument required="true" name="contactAddress" type="string">
        <cfargument required="true" name="contactStreet" type="string">
        <cfargument required="true" name="contactDistrict" type="string">
        <cfargument required="true" name="contactState" type="string">
        <cfargument required="true" name="contactCountry" type="string">
        <cfargument required="true" name="contactPincode" type="string">
        <cfargument required="true" name="contactEmail" type="string">
        <cfargument required="true" name="contactPhone" type="string">
        <cfargument required="true" name="roleIdsToInsert" type="string">
        <cfargument required="true" name="roleIdsToDelete" type="string">
        <cfset local.response = StructNew()>
        <cfset local.contactImage = "demo-contact-image.png">

        <cfif StructKeyExists(session, "isLoggedIn")>
			<cfquery name="local.getEmailPhoneQuery">
				SELECT
					contactid
				FROM
					contactDetails
				WHERE
					createdBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
					AND email = <cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">
					AND active = 1
			</cfquery>
			<cfif local.getEmailPhoneQuery.RecordCount AND local.getEmailPhoneQuery.contactid NEQ arguments.contactId>
                <cfset local.response["statusCode"] = 409>
                <cfset local.response["message"] = "Email id already exists">
			<cfelse>
				<cfif arguments.contactImage NEQ "">
					<cffile action="upload" destination="#expandpath("../assets/contactImages")#" fileField="contactImage" nameconflict="MakeUnique">
					<cfset local.contactImage = cffile.serverFile>
				</cfif>
				<cfif len(trim(arguments.contactId)) EQ 0>
					<cfquery name="local.insertContactsQuery" result="local.insertContactsResult">
						INSERT INTO
							contactDetails (
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
							<cfqueryparam value = "#arguments.contactTitle#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactFirstName#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactLastName#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactGender#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactDOB#" cfsqltype = "cf_sql_date">,
							<cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactAddress#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactStreet#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactDistrict#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactState#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactCountry#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactPincode#" cfsqltype = "cf_sql_char">,
							<cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#arguments.contactPhone#" cfsqltype = "cf_sql_varchar">,
							<cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
						);
					</cfquery>

					<cfif len(trim(arguments.roleIdsToInsert))>
						<cfquery name="local.addRolesQuery">
							INSERT INTO
								contactRoles (
									contactId,
									roleId
								)
							VALUES
							<cfloop list="#arguments.roleIdsToInsert#" index="local.i" item="local.roleId">
								(
									<cfqueryparam value="#local.insertContactsResult.GENERATEDKEY#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#local.roleId#" cfsqltype="cf_sql_integer">
								)
								<cfif local.i LT listLen(arguments.roleIdsToInsert)>,</cfif>
							</cfloop>
						</cfquery>
					</cfif>

					<cfset local.response["statusCode"] = 200>
					<cfset local.response["message"] = "Contact Added Successfully">
				<cfelse>
					<cfquery name="local.updateContactDetailsQuery">
						UPDATE
							contactDetails
						SET
							title = <cfqueryparam value = "#arguments.contactTitle#" cfsqltype = "cf_sql_varchar">,
							firstName = <cfqueryparam value = "#arguments.contactFirstName#" cfsqltype = "cf_sql_varchar">,
							lastName = <cfqueryparam value = "#arguments.contactLastName#" cfsqltype = "cf_sql_varchar">,
							gender = <cfqueryparam value = "#arguments.contactGender#" cfsqltype = "cf_sql_varchar">,
							dob = <cfqueryparam value = "#arguments.contactDOB#" cfsqltype = "cf_sql_date">,
							address = <cfqueryparam value = "#arguments.contactAddress#" cfsqltype = "cf_sql_varchar">,
							street = <cfqueryparam value = "#arguments.contactStreet#" cfsqltype = "cf_sql_varchar">,
							district = <cfqueryparam value = "#arguments.contactDistrict#" cfsqltype = "cf_sql_varchar">,
							STATE = <cfqueryparam value = "#arguments.contactState#" cfsqltype = "cf_sql_varchar">,
							country = <cfqueryparam value = "#arguments.contactCountry#" cfsqltype = "cf_sql_varchar">,
							pincode = <cfqueryparam value = "#arguments.contactPincode#" cfsqltype = "cf_sql_varchar">,
							email = <cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">,
							phone = <cfqueryparam value = "#arguments.contactPhone#" cfsqltype = "cf_sql_varchar">,
							<cfif arguments.contactImage NEQ "">
								contactpicture = <cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
							</cfif>
							updatedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
						WHERE
							contactid = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">
					</cfquery>

					<cfquery name="local.deleteRoleQuery">
						UPDATE
							contactRoles
						SET
							active = 0,
							deletedBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_varchar">
						WHERE
							contactId = <cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_integer">
							AND roleId IN (
								<cfqueryparam value="#arguments.roleIdsToDelete#" cfsqltype="cf_sql_varchar" list="true">
							)
					</cfquery>

					<cfif len(trim(arguments.roleIdsToInsert))>
						<cfquery name="local.addRolesQuery">
							INSERT INTO
								contactRoles (
									contactId,
									roleId
								)
							VALUES
							<cfloop list="#arguments.roleIdsToInsert#" index="local.i" item="local.roleId">
								(
									<cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#local.roleId#" cfsqltype="cf_sql_integer">
								)
								<cfif local.i LT listLen(arguments.roleIdsToInsert)>,</cfif>
							</cfloop>
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

	<cffunction  name="getRoleDetails" returnType="query" access="public">
		<cfquery name="local.getContactRoleDetailsQuery">
			SELECT
				roleId,
				roleName
			FROM
				roleDetails
		</cfquery>

		<cfreturn local.getContactRoleDetailsQuery>
	</cffunction>

    <cffunction name="createContactsFile" returnType="string" returnFormat="json" access="remote">
		<cfargument required="true" name="file" type="string" default="">
		<cfset local.fileName = "#session.fullName#-#DateTimeFormat(Now(), "yyyy-mm-dd-HH-nn-ss")#">

		<cfif arguments.file EQ "pdf">
			<cfset local.createFileQuery = getFullContacts()>
			<cfset local.fileName = local.fileName & ".pdf">
			<cfdocument format="pdf" filename="../assets/pdfs/#local.fileName#" overwrite="true">
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
							<cfloop query="local.createFileQuery">
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
		<cfelseif arguments.file EQ "excel">
			<cfset local.createFileQuery = getFullContacts()>
			<cfset QueryDeleteColumn(local.createFileQuery, "contactpicture")>
			<cfset local.fileName = local.fileName & ".xlsx">
		    <cfspreadsheet action="write" filename="../assets/spreadsheets/#local.fileName#" query="local.createFileQuery" sheetname="contacts" overwrite=true>
		<cfelseif arguments.file EQ "excelTemplate">
			<cfset local.createFileQuery = getFullContacts(usage = "excelTempate")>
			<cfset QueryDeleteColumn(local.createFileQuery, "contactpicture")>
			<cfset local.fileName = "Plain_Template.xlsx">
		    <cfspreadsheet action="write" filename="../assets/spreadsheets/#local.fileName#" query="local.createFileQuery" sheetname="contacts" overwrite=true>
		<cfelseif arguments.file EQ "excelTemplateWithData">
			<cfset local.createFileQuery = getFullContacts()>
			<cfset QueryDeleteColumn(local.createFileQuery, "contactpicture")>
			<cfset local.fileName = local.fileName & ".xlsx">
		    <cfspreadsheet action="write" filename="../assets/spreadsheets/#local.fileName#" query="local.createFileQuery" sheetname="contacts" overwrite=true>
		</cfif>

		<cfreturn local.fileName>
	</cffunction>

	<cffunction name="uploadExcel" returnType="struct" returnFormat="json" access="remote">
		<cfargument name="uploadExcel" type="string" required="true">
		<cfset local.response = StructNew()>
		<cfset local.response["statusCode"] = 200>
		<cfset local.response["fileName"] = "#session.fullName#-contactsUploadResult-#DateTimeFormat(Now(), "yyyy-mm-dd-HH-nn-ss")#.xlsx">

		<cfspreadsheet action="read" src="#arguments.uploadExcel#" query="local.excelUploadDataQuery" headerrow="1" excludeHeaderRow=true>
		<cfset local.resultExcelQuery = Duplicate(local.excelUploadDataQuery)>
		<cfset local.roleDetailsQuery = getRoleDetails()>

		<!--- Mapping roleid to rolename --->
		<cfset local.roleNameToId = {}>
		<cfloop query="local.roleDetailsQuery">
			<cfset local.roleNameToId[local.roleDetailsQuery.roleName] = local.roleDetailsQuery.roleId>
		</cfloop>

		<cfset local.resultColumnValues = []>
		<cfloop query="local.excelUploadDataQuery">
			<cfset local.valid = true>
			<cfset local.currentRoleIds = "">
			<cfset local.resultColumnValue = "">

			<!--- Get New rolenames and roleids --->
			<cfloop list="#local.excelUploadDataQuery.roles#" item="local.roleName">
				<cfif structKeyExists(local.roleNameToId, local.roleName)>
					<cfset local.currentRoleIds = ListAppend(local.currentRoleIds, local.roleNameToId[local.roleName])>
				</cfif>
			</cfloop>

			<!--- Missing data validation --->
			<cfset local.missingColumnNames = []>
			<cfloop list="#local.excelUploadDataQuery.columnList#" item="local.columnName">
				<cfif local.excelUploadDataQuery[local.columnName].toString() == "">
					<cfset ArrayAppend(local.missingColumnNames, local.columnName)>
				</cfif>
			</cfloop>
			<cfif ArrayLen(local.missingColumnNames)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, ArrayToList(local.missingColumnNames) & " Missing")>
			</cfif>

			<!--- Title validation --->
			<cfif len(local.excelUploadDataQuery.title) AND NOT ArrayFind(["Mr.", "Miss.", "Ms.", "Mrs."], local.excelUploadDataQuery.title)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Title should be one in [Mr., Miss., Ms., or Mrs.]")>
			</cfif>

			<!--- FirstName validation --->
			<cfif len(local.excelUploadDataQuery.firstname) AND NOT REFind("^[a-zA-Z ]+$", local.excelUploadDataQuery.firstname)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Firstname should only contain letters and spaces")>
			</cfif>

			<!--- LastName validation --->
			<cfif len(local.excelUploadDataQuery.lastname) AND NOT REFind("^[a-zA-Z ]+$", local.excelUploadDataQuery.lastname)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Lastname should only contain letters and spaces")>
			</cfif>

			<!--- Gender validation --->
			<cfif len(local.excelUploadDataQuery.gender) AND NOT ArrayFind(["Male", "Female", "Others"], local.excelUploadDataQuery.gender)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Gender should be one in [Male, Female, Others]")>
			</cfif>

			<!--- Date of Birth validation --->
			<cfif len(local.excelUploadDataQuery.dob)>
				<cfif NOT isDate(local.excelUploadDataQuery.dob)>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "DOB is not valid - It should be in format of yyyy-mm-dd")>
				<cfelseif DateCompare(local.excelUploadDataQuery.dob, Now(), "d") NEQ -1>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "DOB should not be in the future")>
				</cfif>
			</cfif>

			<!--- Pincode validation --->
			<cfif len(local.excelUploadDataQuery.pincode)>
				<cfset local.formattedPincode = trim(replace(local.excelUploadDataQuery.pincode, "-", ""))>
				<cfif NOT isNumeric(local.formattedPincode)>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Pincode should contain only digits")>
				<cfelseif len(local.formattedPincode) NEQ 6>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Pincode length should be 6 characters")>
				</cfif>
			</cfif>

			<!--- Email validation --->
			<cfif len(local.excelUploadDataQuery.email) AND NOT isValid("email", local.excelUploadDataQuery.email)>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Email not valid")>
			</cfif>

			<!--- Phone number validation --->
			<cfif len(local.excelUploadDataQuery.phone)>
				<cfset local.formattedPhone = trim(replace(local.excelUploadDataQuery.phone, "-", ""))>
				<cfif NOT isNumeric(local.formattedPhone)>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Phone number should contain only digits")>
				<cfelseif len(local.formattedPhone) NEQ 10>
					<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Phone number length should be 10 characters")>
				</cfif>
			</cfif>

			<!--- Role Validation --->
			<cfset local.userGivenRoleNameList = local.excelUploadDataQuery.roles>
			<cfset local.validRoleNameList = ValueList(local.roleDetailsQuery.roleName)>
			<cfset local.foundDifference = false>
			<cfif local.userGivenRoleNameList neq "" AND local.validRoleNameList neq "">
				<cfloop list="#local.userGivenRoleNameList#" index="item">
					<cfif NOT ListFind(local.validRoleNameList, trim(item))>
						<cfset local.foundDifference = true>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>
			<cfif len(local.excelUploadDataQuery.roles) AND local.foundDifference>
				<cfset local.resultColumnValue = ListAppend(local.resultColumnValue, "Roles are not valid - Valid rolenames are " & local.validRoleNameList)>
			</cfif>

			<cfif len(trim(local.resultColumnValue))>
				<cfset local.response["statusCode"] = 422>
				<cfset ArrayAppend(local.resultColumnValues, local.resultColumnValue)>
			<cfelse>
				<!--- Check Email Existence --->
				<cfquery name="local.checkEmailQuery">
					SELECT
						cd.contactid,
						ISNULL(STRING_AGG(CONVERT(VARCHAR(36), cr.roleId), ','), '') AS previousRoleIds
					FROM
						contactDetails cd LEFT JOIN contactRoles cr ON cd.contactid = cr.contactId
					WHERE
						cd.email = <cfqueryparam value="#local.excelUploadDataQuery.email#" cfsqltype="cf_sql_varchar">
						AND cd.createdBy = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
						AND cd.active = 1
						AND cr.active = 1
					GROUP BY
						cd.contactid
				</cfquery>

				<cfif QueryRecordCount(local.checkEmailQuery)>
					<!--- Create Contact --->
					<cfset modifyContacts(
						contactId = local.checkEmailQuery.contactid,
						contactTitle = local.excelUploadDataQuery.title,
						contactFirstName = local.excelUploadDataQuery.firstname,
						contactLastName = local.excelUploadDataQuery.lastname,
						contactGender = local.excelUploadDataQuery.gender,
						contactDOB = local.excelUploadDataQuery.dob,
						contactImage = "",
						contactAddress = local.excelUploadDataQuery.address,
						contactStreet = local.excelUploadDataQuery.street,
						contactDistrict = local.excelUploadDataQuery.district,
						contactState = local.excelUploadDataQuery.state,
						contactCountry = local.excelUploadDataQuery.country,
						contactPincode = local.excelUploadDataQuery.pincode,
						contactEmail = local.excelUploadDataQuery.email,
						contactPhone = local.excelUploadDataQuery.phone,
						roleIdsToInsert = ListFilter(local.currentRoleIds, function(roleId) {
							return NOT ListFind(checkEmailQuery.previousRoleIds, roleId)
						}),
						roleIdsToDelete = ListFilter(local.checkEmailQuery.previousRoleIds, function(roleId) {
							return NOT ListFind(currentRoleIds, roleId)
						})
					)>
					<cfset ArrayAppend(local.resultColumnValues, "Updated")>
				<cfelse>
					<!--- Edit Contact --->
					<cfset modifyContacts(
						contactId = "",
						contactTitle = local.excelUploadDataQuery.title,
						contactFirstName = local.excelUploadDataQuery.firstname,
						contactLastName = local.excelUploadDataQuery.lastname,
						contactGender = local.excelUploadDataQuery.gender,
						contactDOB = local.excelUploadDataQuery.dob,
						contactImage = "",
						contactAddress = local.excelUploadDataQuery.address,
						contactStreet = local.excelUploadDataQuery.street,
						contactDistrict = local.excelUploadDataQuery.district,
						contactState = local.excelUploadDataQuery.state,
						contactCountry = local.excelUploadDataQuery.country,
						contactPincode = local.excelUploadDataQuery.pincode,
						contactEmail = local.excelUploadDataQuery.email,
						contactPhone = local.excelUploadDataQuery.phone,
						roleIdsToInsert = local.currentRoleIds,
						roleIdsToDelete = ""
					)>
					<cfset ArrayAppend(local.resultColumnValues, "Added")>
				</cfif>
			</cfif>

		</cfloop>
		<cfif QueryKeyExists(local.resultExcelQuery, "Result")>
			<cfset QueryDeleteColumn(local.resultExcelQuery, "Result")>
		</cfif>
		<cfset QueryAddColumn(local.resultExcelQuery, "Result", local.resultColumnValues)>

		<!--- Query Sorting --->
		<cfset local.sortedQuery = QuerySort(local.resultExcelQuery, function(obj1, obj2){
			var check1 = FindNoCase("added", obj1.result) OR FindNoCase("updated", obj1.result);
			var check2 = FindNoCase("added", obj2.result) OR FindNoCase("updated", obj2.result);

			if (check1 AND NOT check2) {
				return 1;
			}
			else if (check2 AND NOT check1) {
				return -1;
			}
			return 0;
		})>
		<cfspreadsheet action="write" filename="../assets/spreadsheets/#local.response.fileName#" query="local.resultExcelQuery" sheetname="contacts" overwrite=true>
		<cfreturn local.response>
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
				SELECT
					cd.title,
					cd.firstname,
					cd.lastname,
					cd.dob,
					cd.email,
					u.fullname AS createdUser
				FROM
					contactDetails cd
					JOIN users u ON cd.createdBy = u.userid
				WHERE
					createdBy = <cfqueryparam value = "#arguments.userId#" cfsqltype = "cf_sql_varchar">
					AND active = 1
			</cfquery>

			<cfloop query="local.getUsersAndDOB">
				<cfif Day(dob) EQ Day(Now()) AND Month(dob) EQ Month(Now())>
					<cfmail from="test@test.com" to="#local.getUsersAndDOB.email#" subject="Birthday Wishes">
						Good Morning #local.getUsersAndDOB.title# #local.getUsersAndDOB.firstname# #local.getUsersAndDOB.lastname#,
						On behalf of #local.getUsersAndDOB.createdUser#, we are wishing you a happy birthday and many more happy returns of the day.
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
