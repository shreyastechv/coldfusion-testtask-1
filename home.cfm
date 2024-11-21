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
		<cfoutput>
			<header class="header d-flex align-items-center justify-content-between fixed-top px-5">
				<a class="d-flex align-items-center text-decoration-none" href="##">
					<img class="logo" src="./assets/images/logo.png" alt="Logo Image">
					<div class="text-white">ADDRESS BOOK</div>
				</a>
				<nav class="d-flex align-items-center gap-4">
					<a class="text-white text-decoration-none" href="##" onclick="logOut()">
						<i class="fa-solid fa-right-from-bracket"></i>
						Logout
					</a>
				</nav>
			</header>

			<div class="container-fluid px-5 py-2 my-5">
				<div id="submitMsgSection" class="text-danger text-center p-2"></div>
				<div class="px-1 w-100 bg-white rounded-1 d-flex align-items-center justify-content-end">
					<button onclick="createPdf()" class="btn">
						<img class="toolbarIcon p-1" src="./assets/images/pdficon.png" alt="PDF Icon">
					</button>
					<button onclick="createExcel()" class="btn">
						<img class="toolbarIcon" src="./assets/images/excelicon.png" alt="Excel Icon">
					</button>
					<button onclick="window.print()" class="btn">
						<img class="toolbarIcon p-1" src="./assets/images/printericon.png" alt="Printer Icon">
					</button>
				</div>
				<div class="row p-3 d-flex flex-nowrap gap-2">
					<div class="col-md-3 px-2 py-4 bg-white rounded-1 d-flex flex-column align-items-center gap-4">
						<cfif StructKeyExists(session, "profilePicture")>
							<img class="userProfileIcon" src="./assets/profilePictures/#session.profilePicture#" alt="User Profile Icon">
						<cfelse>
							<img class="userProfileIcon" src="./assets/images/user-profileicon.png" alt="User Profile Icon">
						</cfif>
						<cfif StructKeyExists(session, "fullName")>
							<h4>#session.fullName#</h4>
						<cfelse>
							<h4>User Fullname</h4>
						</cfif>
						<button class="btn bg-primary text-white rounded-pill" onclick="createContact()">CREATE CONTACT</button>
					</div>
					<div class="col-md-9 bg-white rounded-1 p-3">
						<table class="table table-hover align-middle">
							<thead>
								<tr>
									<th></th>
									<th>NAME</th>
									<th>EMAIL ID</th>
									<th>PHONE NUMBER</th>
									<th></th>
									<th></th>
									<th></th>
								</tr>
							</thead>
							<tbody>
								<cfset local.contactsObject = CreateObject("component", "components.addressbook")>
								<cfset session.getContactsQuery = contactsObject.getContacts()>
								<cfloop query="session.getContactsQuery">
									<tr>
										<td>
											<img class="contactImage p-2" src="./assets/contactImages/#contactpicture#" alt="Contact Image">
										</td>
										<td>#firstname# #lastname#</td>
										<td>#email#</td>
										<td>#phone#</td>
										<td>
											<button class="actionBtn btn btn-outline-primary rounded-pill px-4" value="#contactid#" onclick="editContact(event)">EDIT</button>
										</td>
										<td>
											<button class="actionBtn btn btn-outline-danger rounded-pill px-3" value="#contactid#" onclick="deleteContact(event)">DELETE</button>
										</td>
										<td>
											<button class="actionBtn btn btn-outline-info rounded-pill px-3" value="#contactid#" onclick="viewContact(event)">VIEW</button>
										</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
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
										</div>
										<div class="col-md-4">
											<label class="contactManagementLabel" for="editContactFirstname">First Name *</label>
											<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="editContactFirstname" name="editContactFirstname" placeholder="Enter First Name">
										</div>
										<div class="col-md-4">
											<label class="contactManagementLabel" for="editContactLastname">Last Name *</label>
											<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="editContactLastname" name="editContactLastname" placeholder="Enter Last Name">
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
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactDOB">Date Of Birth *</label>
											<input class="contactManagementInput py-1 mt-0" type="date" id="editContactDOB" name="editContactDOB">
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
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactAddress" name="editContactAddress" placeholder="Enter Address" autocomplete="address">
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactStreet">Street *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactStreet" name="editContactStreet" placeholder="Enter Street Name">
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactDistrict">District *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactDistrict" name="editContactDistrict" placeholder="Enter District">
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactState">State *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactState" name="editContactState" placeholder="Enter State">
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactCountry">Country *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" id="editContactCountry" name="editContactCountry" placeholder="Enter Country" autocomplete="country">
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactPincode">Pincode *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" maxlength="6" id="editContactPincode" name="editContactPincode" placeholder="Enter Pincode">
										</div>
									</div>
									<div class="d-flex justify-content-between gap-3 mb-3">
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactEmail">Email Id *</label>
											<input class="contactManagementInput py-1 mt-1" type="email" id="editContactEmail" name="editContactEmail" placeholder="Enter Email Id" autocomplete="email">
										</div>
										<div class="col-md-6">
											<label class="contactManagementLabel" for="editContactPhone">Phone number *</label>
											<input class="contactManagementInput py-1 mt-1" type="text" maxlength="10" id="editContactPhone" name="editContactPhone" placeholder="Enter Phone number" autocomplete="tel">
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
		<script>
			function logOut() {
				if (confirm("Confirm logout")) {
					const submitMsgSection = $("#submitMsgSection");

					$.ajax({
						type: "POST",
						url: "./components/addressbook.cfc?method=logOut",
						success: function(response) {
							const responseJSON = JSON.parse(response);
							if (responseJSON.statusCode === 0) {
								location.reload();
							}
							else {
								submitMsgSection.text(responseJSON.message);
							}
						},
						error: function (xhr, ajaxOptions, thrownError) {
							submitMsgSection.text("We encountered an error! Error details are: " + thrownError);
						}
					});
				}
			}

			function viewContact(event) {
				const viewContactName = $("#viewContactName");
				const viewContactGender = $("#viewContactGender");
				const viewContactDOB = $("#viewContactDOB");
				const viewContactAddress = $("#viewContactAddress");
				const viewContactPincode = $("#viewContactPincode");
				const viewContactEmail = $("#viewContactEmail");
				const viewContactPhone = $("#viewContactPhone");
				const viewContactPicture = $("#viewContactPicture");

				$.ajax({
                    type: "POST",
                    url: "./components/addressbook.cfc?method=getContactById",
					data: { contactId: event.target.value },
                    success: function(response) {
						const responseJSON = JSON.parse(response);
						const { TITLE, FIRSTNAME, LASTNAME, GENDER, DOB, CONTACTPICTURE, ADDRESS, STREET, DISTRICT, STATE, COUNTRY, PINCODE, EMAIL, PHONE } = responseJSON;
						viewContactName.text(`${TITLE} ${FIRSTNAME} ${LASTNAME}`);
						viewContactGender.text(GENDER);
						viewContactDOB.text(DOB.split(" ", 3).join(" "));
						viewContactAddress.text(`${ADDRESS}, ${STREET}, ${DISTRICT}, ${STATE}, ${COUNTRY}`);
						viewContactPincode.text(PINCODE);
						viewContactEmail.text(EMAIL);
						viewContactPhone.text(PHONE);
						viewContactPicture.attr("src", `./assets/contactImages/${CONTACTPICTURE}`);
						$('#viewContactModal').modal('show');
                    }
                });
			}

			function deleteContact(event) {
				if (confirm("Delete this contact?")) {
					$.ajax({
						type: "POST",
						url: "./components/addressbook.cfc?method=deleteContact",
						data: { contactId: event.target.value },
						success: function(response) {
							const responseJSON = JSON.parse(response);
							if (responseJSON.statusCode === 0) {
								location.reload();
							}
						}
					});
				}
			}

			function createContact() {
				$("#contactManagementHeading").text("CREATE CONTACT");
				$("#contactManagement")[0].reset();
				$("#editContactId").val("");
				$('#contactManagementModal').modal('show');
			}

			function editContact(event) {
				$("#contactManagementHeading").text("EDIT CONTACT");

				$.ajax({
                    type: "POST",
                    url: "./components/addressbook.cfc?method=getContactById",
					data: { contactId: event.target.value },
                    success: function(response) {
						const responseJSON = JSON.parse(response);
						const { CONTACTID, TITLE, FIRSTNAME, LASTNAME, GENDER, DOB, CONTACTPICTURE, ADDRESS, STREET, DISTRICT, STATE, COUNTRY, PINCODE, EMAIL, PHONE } = responseJSON;

						$("#editContactId").val(CONTACTID);
						$("#editContactTitle").val(TITLE);
						$("#editContactFirstname").val(FIRSTNAME);
						$("#editContactLastname").val(LASTNAME);
						$("#editContactGender").val(GENDER);
						const formattedDOB = DOB.replace(",", "");
						const dob = new Date(formattedDOB);
						const year = dob.getFullYear();
						let month = dob.getMonth()+1;
						if (month < 10) month = '0' + month;
						let day = dob.getDate();
						if (day < 10) day = '0' + day;
						$("#editContactDOB").val(`${year}-${month}-${day}`);
						$("#editContactPicture").attr("src", `./assets/contactImages/${CONTACTPICTURE}`);
						$("#editContactAddress").val(ADDRESS);
						$("#editContactStreet").val(STREET);
						$("#editContactDistrict").val(DISTRICT);
						$("#editContactState").val(STATE);
						$("#editContactCountry").val(COUNTRY);
						$("#editContactPincode").val(PINCODE);
						$("#editContactEmail").val(EMAIL);
						$("#editContactPhone").val(PHONE);
						$('#contactManagementModal').modal('show');
                    }
                });
			}

			$("#contactManagement").submit(function(event) {
                event.preventDefault();
                const contactManagementMsgSection = $("#contactManagementMsgSection");
				const thisForm = $(this)[0];
                const formData = new FormData(thisForm);

                $.ajax({
                    type: "POST",
                    url: "./components/addressbook.cfc?method=modifyContacts",
                    data: formData,
					enctype: 'multipart/form-data',
					processData: false,
					contentType: false,
                    success: function(response) {
                        const responseJSON = JSON.parse(response);
                        if (responseJSON.statusCode === 0) {
							if ($("#editContactId").val() === "") {
								$("#contactManagement")[0].reset();
							}
							contactManagementMsgSection.css("color", "green");
							location.reload();
                        }
						else {
							contactManagementMsgSection.css("color", "red");
						}
                        contactManagementMsgSection.text(responseJSON.message);
                    },
                    error: function (xhr, ajaxOptions, thrownError) {
                        contactManagementMsgSection.text("We encountered an error! Error details are: " + thrownError);
                    }
                });
            });
		</script>
    </body>
</html>
