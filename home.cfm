<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Home Page - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/home.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
		<script src="./js/jquery-3.7.1.min.js"></script>
    </head>

    <body>
		<cfset ormReload()>
		<cfset contacts = entityLoad("contactDetailsORM", {createdBy = session.userId, active = 1})>
		<cfoutput>
			<!--- Navbar --->
			<nav class="navbar navbar-expand-lg shadow-sm customNavbar px-2">
				<div class="container-fluid">
					<a class="navbar-brand text-white" href="/">
						<img src="./assets/images/logo.png" alt="Logo" width="30" height="30" class="d-inline-block align-text-top">
						ADDRESS BOOK
					</a>
					<a class="text-white text-decoration-none d-print-none" href="/" onclick="logOut()">
						<i class="fa-solid fa-right-from-bracket"></i>
						Logout
					</a>
				</div>
			</nav>

			<!--- Main Content --->
			<div class="container-fluid contentSection">
				<!--- Toolbar --->
				<div class="toolbar d-flex justify-content-end d-print-none">
					<button onclick="createPdf()" class="btn" data-bs-toggle="tooltip" data-bs-placement="bottom" data-bs-title="Create PDF from contact list">
						<img class="toolbarIcon p-1" src="./assets/images/pdficon.png" alt="PDF Icon">
					</button>
					<button onclick="createExcel()" class="btn" data-bs-toggle="tooltip" data-bs-placement="bottom" data-bs-title="Create Spreadsheet from contact list">
						<img class="toolbarIcon" src="./assets/images/excelicon.png" alt="Excel Icon">
					</button>
					<button onclick="window.print()" class="btn" data-bs-toggle="tooltip" data-bs-placement="bottom" data-bs-title="Print the page">
						<img class="toolbarIcon p-1" src="./assets/images/printericon.png" alt="Printer Icon">
					</button>
				</div>

				<!--- Bottom Content --->
				<div class="row px-1 pe-md-3">
					<!--- Left Section --->
					<div class="col-lg-3 col-md-4 col-12 sidebar bg-transparent mb-2">
						<div class="bg-white d-flex flex-column align-items-center px-3 py-5 gap-2">
							<cfif StructKeyExists(session, "profilePicture")>
								<img class="userProfileIcon rounded-4" src="#session.profilePicture#" alt="User Profile Icon">
							<cfelse>
								<img class="userProfileIcon rounded-4" src="./assets/images/user-profileicon.png" alt="User Profile Icon">
							</cfif>
							<cfif StructKeyExists(session, "fullName")>
								<h4>#session.fullName#</h4>
							<cfelse>
								<h4>User Fullname</h4>
							</cfif>
							<button class="btn bg-primary text-white rounded-pill d-print-none" onclick="createContact()">CREATE CONTACT</button>
							<button id="scheduleBdayEmailBtn" class="btn bg-secondary text-white rounded-pill d-print-none" onclick="toggleBdayEmailSchedule()">SCHEDULE BDAY MAILS</button>
						</div>
					</div>
					<!--- Right Section --->
					<div class="col-lg-9 col-md-8 col-12 mainContent bg-white d-flex align-items-center justify-content-around">
						<cfif arrayLen(contacts)>
							<div class="table-responsive w-100">
								<table class="table table-hover align-middle">
									<thead>
										<tr>
											<th></th>
											<th>NAME</th>
											<th>EMAIL ID</th>
											<th>PHONE NUMBER</th>
											<th class="d-print-none"></th>
											<th class="d-print-none"></th>
											<th class="d-print-none"></th>
										</tr>
									</thead>
									<tbody>
										<cfloop array="#contacts#" item="contactItem">
											<tr>
												<td>
													<img class="contactImage p-2 rounded-4" src="./assets/contactImages/#contactItem.getContactpicture()#" alt="Contact Image">
												</td>
												<td>#contactItem.getFirstName()# #contactItem.getLastName()#</td>
												<td>#contactItem.getEmail()#</td>
												<td>#contactItem.getPhone()#</td>
												<td class="d-print-none">
													<button class="actionBtn btn btn-outline-primary rounded-pill px-3" value="#contactItem.getContactId()#" onclick="editContact(event)">
														<span class="d-none d-lg-inline pe-none">EDIT</span>
														<i class="fa-solid fa-pen-to-square d-lg-none pe-none"></i>
													</button>
												</td>
												<td class="d-print-none">
													<button class="actionBtn btn btn-outline-danger rounded-pill px-3" value="#contactItem.getContactId()#" onclick="deleteContact(event)">
														<span class="d-none d-lg-inline pe-none">DELETE</span>
														<i class="fa-solid fa-trash d-lg-none pe-none"></i>
													</button>
												</td>
												<td class="d-print-none">
													<button class="actionBtn btn btn-outline-info rounded-pill px-3" value="#contactItem.getContactId()#" onclick="viewContact(event)">
														<span class="d-none d-lg-inline pe-none">VIEW</span>
														<i class="fa-solid fa-eye d-lg-none pe-none"></i>
													</button>
												</td>
											</tr>
										</cfloop>
									</tbody>
								</table>
							</div>
						<cfelse>
							<div class="d-flex fs-5 text-info justify-content-center">No contacts to display.</div>
						</cfif>
					</div>
				</div>
			</div>

			<!--- View Contact Modal --->
			<div class="modal fade" id="viewContactModal" tabindex="-1" aria-labelledby="viewContactModalLabel" aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content rounded-0 d-flex flex-row justify-content-around">
						<div>
							<div class="modal-header d-flex justify-content-around border-bottom-0">
								<div class="contactModalHeader customDarkBlue px-5">
									<h5 class="m-1">CONTACT DETAILS</h5>
								</div>
							</div>
							<div class="modal-body">
								<table class="table table-borderless align-middle">
									<tbody>
										<tr>
											<td class="text-primary fw-semibold">Name</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactName">Miss. Anjana S</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Gender</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactGender">Female</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Date Of Birth</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactDOB">12-05-2002</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Address</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactAddress">sdfsad, sadasd, Thiruvananthapuram, Kerala, India</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Pincode</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactPincode">567658</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Email id</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactEmail">anjana@gmail.com</td>
										</tr>
										<tr>
											<td class="text-primary fw-semibold">Phone</td>
											<td class="text-primary fw-semibold">:</td>
											<td id="viewContactPhone">9876567487</td>
										</tr>
									</tbody>
								</table>
							</div>
							<div class="modal-footer d-flex justify-content-around border-top-0">
								<button type="button" class="btn text-white bg-customDarkBlue rounded-pill py-1 px-4" data-bs-dismiss="modal">CLOSE</button>
							</div>
						</div>
						<div class="contactImageEnlarged d-flex align-items-center justify-content-end p-4">
							<img id="viewContactPicture" src="./assets/contactImages/demo-contact-image.png" alt="Contact Image Enlarged">
						</div>
					</div>
				</div>
			</div>

			<!--- Contact Management Modal --->
			<div class="modal fade" id="contactManagementModal" tabindex="-1" aria-labelledby="contactManagementModalLabel" aria-hidden="true">
				<div class="modal-dialog">
					<div class="modal-content rounded-0 d-flex flex-row justify-content-around">
						<div>
							<form id="contactManagement" name="contactManagement" method="post" enctype="multipart/form-data">
								<input type="hidden" id="editContactId" name="editContactId">
								<div class="modal-header d-flex justify-content-around border-bottom-0">
									<div class="contactModalHeader customDarkBlue px-5">
										<h5 id="contactManagementHeading" class="m-1">CREATE CONTACT</h5>
									</div>
								</div>
								<div class="modal-body">
									<h6 class="text-primary my-1">Personal Contact</h6>
									<hr class="border border-dark border-1 opacity-100 m-0 mb-2">
									<div class="d-flex justify-content-between mb-3">
										<div class="col-md-2">
											<label class="contactManagementLabel" for="editContactTitle">Title *</label>
											<select class="contactManagementInput py-1 mt-1" id="editContactTitle" name="editContactTitle">
												<option></option>
												<option>Mr.</option>
												<option>Miss.</option>
												<option>Ms.</option>
												<option>Mrs.</option>
											</select>
											<div class="error text-danger" id="titleError"></div>
										</div>
										<div class="col-md-4">
											<label class="contactManagementLabel" for="editContactFirstname">First Name *</label>
											<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="editContactFirstname" name="editContactFirstname" placeholder="Enter First Name" maxlength="30">
											<div class="error text-danger" id="firstNameError"></div>
										</div>
										<div class="col-md-4">
											<label class="contactManagementLabel" for="editContactLastname">Last Name *</label>
											<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="editContactLastname" name="editContactLastname" placeholder="Enter Last Name" maxlength="30">
											<div class="error text-danger" id="lastNameError"></div>
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6 d-flex flex-column">
											<label class="contactManagementLabel" for="editContactGender">Gender *</label>
											<select class="contactManagementInput py-1 mt-1" id="editContactGender" name="editContactGender">
												<option></option>
												<option>Male</option>
												<option>Female</option>
												<option>Others</option>
											</select>
											<div class="error text-danger" id="genderError"></div>
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactDOB">Date Of Birth *</label>
											<input class="contactManagementInput py-1 mt-0" type="date" id="editContactDOB" name="editContactDOB" max="#DateFormat(Now(), 'yyyy-mm-dd')#">
											<div class="error text-danger" id="dobError"></div>
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-9 w-75">
											<label class="contactManagementLabel" for="editContactImage">Upload Photo</label>
											<input class="contactManagementInput py-1 mt-1" type="file" id="editContactImage" name="editContactImage" accept="image/*">
										</div>
									</div>
									<h6 class="text-primary my-1">Contact Details</h6>
									<hr class="border border-dark border-1 opacity-100 m-0 mb-2">
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactAddress">Address *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactAddress" name="editContactAddress" placeholder="Enter Address" autocomplete="address" maxlength="40">
											<div class="error text-danger" id="addressError"></div>
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactStreet">Street *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactStreet" name="editContactStreet" placeholder="Enter Street Name" maxlength="15">
											<div class="error text-danger" id="streetError"></div>
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactDistrict">District *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactDistrict" name="editContactDistrict" placeholder="Enter District" maxlength="15">
											<div class="error text-danger" id="districtError"></div>
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactState">State *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactState" name="editContactState" placeholder="Enter State" maxlength="15">
											<div class="error text-danger" id="stateError"></div>
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactCountry">Country *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactCountry" name="editContactCountry" placeholder="Enter Country" autocomplete="country" maxlength="15">
											<div class="error text-danger" id="countryError"></div>
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactPincode">Pincode *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" maxlength="6" id="editContactPincode" name="editContactPincode" placeholder="Enter Pincode">
											<div class="error text-danger" id="pincodeError"></div>
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactEmail">Email Id *</label>
											<input class="contactManagementInput py-1 mt-1" type="email" id="editContactEmail" name="editContactEmail" placeholder="Enter Email Id" autocomplete="email" maxlength="50">
											<div class="error text-danger" id="emailError"></div>
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactPhone">Phone number *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" maxlength="10" id="editContactPhone" name="editContactPhone" placeholder="Enter Phone number" autocomplete="tel">
											<div class="error text-danger" id="phoneError"></div>
										</div>
									</div>
								</div>
								<div id="contactManagementMsgSection" class="text-center p-2"></div>
								<div class="modal-footer d-flex justify-content-around border-top-0">
									<button type="button" class="btn text-white bg-customDarkBlue rounded-pill py-1 px-4" data-bs-dismiss="modal">CLOSE</button>
									<button type="submit" class="btn btn-primary rounded-pill py-1 px-4" id="submitBtn" name="submitBtn">SUBMIT</button>
								</div>
							</form>
						</div>
						<div class="contactImageEnlarged d-flex align-items-center justify-content-end p-4">
							<img id="editContactPicture" src="./assets/profilePictures/demo-profilepicture.png" alt="Contact Image Enlarged">
						</div>
					</div>
				</div>
			</div>
		</cfoutput>
		<script src="./js/bootstrap.bundle.min.js"></script>
		<script src="./js/home.js"></script>
    </body>
</html>
