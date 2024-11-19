<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Log In - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/home.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
		<script src="./js/jquery-3.7.1.min.js"></script>
    </head>

    <body>
        <header class="header d-flex align-items-center justify-content-between fixed-top px-5">
            <a class="d-flex align-items-center text-decoration-none" href="#">
                <img class="logo" src="./assets/images/logo.png" alt="Logo Image">
                <div class="text-white">ADDRESS BOOK</div>
            </a>
            <nav class="d-flex align-items-center gap-4">
                <a class="text-white text-decoration-none" href="#" onclick="logOut()">
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
				<button onclick="return createExcel()" class="btn">
					<img class="toolbarIcon" src="./assets/images/excelicon.png" alt="Excel Icon">
				</button>
				<button onclick="window.print()" class="btn">
					<img class="toolbarIcon p-1" src="./assets/images/printericon.png" alt="Printer Icon">
				</button>
			</div>
			<div class="row p-3 d-flex flex-nowrap gap-2">
				<div class="col-md-3 px-2 py-4 bg-white rounded-1 d-flex flex-column align-items-center gap-4">
					<img class="userProfileIcon" src="./assets/images/user-profileicon.png" alt="User Profile Icon">
					<h4>Merlin Richard</h4>
					<button class="btn bg-primary text-white rounded-pill">CREATE CONTACT</button>
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
							<tr>
								<td>
									<img class="contactImage p-2" src="./assets/images/defaultcontactimage-man.png" alt="Contact Image">
								</td>
								<td>Anjana S</td>
								<td>anjana@gmail.com</td>
								<td>6354826452</td>
								<td>
									<button class="actionBtn btn btn-outline-primary rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#contactManagementModal">EDIT</button>
								</td>
								<td>
									<button class="actionBtn btn btn-outline-danger rounded-pill px-3">DELETE</button>
								</td>
								<td>
									<button class="actionBtn btn btn-outline-info rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#viewContactModal">VIEW</button>
								</td>
							</tr>
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
										<td>Miss. Anjana S</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Gender</td>
										<td class="text-primary fw-semibold">:</td>
										<td>Female</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Date Of Birth</td>
										<td class="text-primary fw-semibold">:</td>
										<td>12-05-2002</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Address</td>
										<td class="text-primary fw-semibold">:</td>
										<td>sdfsad, sadasd, Thiruvananthapuram, Kerala, India</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Pincode</td>
										<td class="text-primary fw-semibold">:</td>
										<td>567658</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Email id</td>
										<td class="text-primary fw-semibold">:</td>
										<td>anjana@gmail.com</td>
									</tr>
									<tr>
										<td class="text-primary fw-semibold">Phone</td>
										<td class="text-primary fw-semibold">:</td>
										<td>9876567487</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="modal-footer d-flex justify-content-around border-top-0">
							<button type="button" class="btn text-white bg-customDarkBlue rounded-pill py-1 px-4" data-bs-dismiss="modal">CLOSE</button>
						</div>
					</div>
					<div class="contactImageEnlarged d-flex align-items-center justify-content-end p-4">
						<img src="./assets/profilePictures/demo-profilepicture.png" alt="Contact Image Enlarged">
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
							<div class="modal-header d-flex justify-content-around border-bottom-0">
								<div class="contactModalHeader customDarkBlue px-5">
									<h5 class="m-1">CREATE CONTACT</h5>
								</div>
							</div>
							<div class="modal-body">
								<h6 class="text-primary my-1">Personal Contact</h6>
								<hr class="border border-dark border-1 opacity-100 m-0 mb-2">
								<div class="d-flex justify-content-between mb-3">
									<div class="col-md-2">
										<label class="contactManagementLabel" for="title">Title *</label>
										<select class="contactManagementInput py-1 mt-1" id="title" name="title">
											<option></option>
											<option>Mr.</option>
											<option>Miss.</option>
											<option>Ms.</option>
											<option>Mrs.</option>
										</select>
									</div>
									<div class="col-md-4">
										<label class="contactManagementLabel" for="firstname">First Name *</label>
										<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="firstname" name="firstname" placeholder="Enter First Name">
									</div>
									<div class="col-md-4">
										<label class="contactManagementLabel" for="lastname">Last Name *</label>
										<input class="contactManagementInput py-1 mt-1 w-100" type="text" id="lastname" name="lastname" placeholder="Enter Last Name">
									</div>
								</div>
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-6 d-flex flex-column">
										<label class="contactManagementLabel" for="gender">Gender *</label>
										<select class="contactManagementInput py-1 mt-1" id="gender" name="gender">
											<option></option>
											<option>Male</option>
											<option>Female</option>
											<option>Others</option>
										</select>
									</div>
									<div class="col-md-6">
										<label class="contactManagementLabel" for="dob">Date Of Birth *</label>
										<input class="contactManagementInput py-1 mt-0" type="date" id="dob" name="dob">
									</div>
								</div>
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-9 w-75">
										<label class="contactManagementLabel" for="profilePhoto">Upload Photo</label>
										<input class="contactManagementInput py-1 mt-1" type="file" id="profilePhoto" name="profilePhoto">
									</div>
								</div>
								<h6 class="text-primary my-1">Contact Details</h6>
								<hr class="border border-dark border-1 opacity-100 m-0 mb-2">
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-6">
										<label class="contactManagementLabel" for="address">Address *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" id="address" name="address" placeholder="Enter Address" autocomplete="address">
									</div>
									<div class="col-md-6">
										<label class="contactManagementLabel" for="street">Street *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" id="street" name="street" placeholder="Enter Street Name">
									</div>
								</div>
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-6">
										<label class="contactManagementLabel" for="district">District *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" id="district" name="district" placeholder="Enter District">
									</div>
									<div class="col-md-6">
										<label class="contactManagementLabel" for="state">State *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" id="state" name="state" placeholder="Enter State">
									</div>
								</div>
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-6">
										<label class="contactManagementLabel" for="country">Country *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" id="country" name="country" placeholder="Enter Country" autocomplete="country">
									</div>
									<div class="col-md-6">
										<label class="contactManagementLabel" for="pincode">Pincode *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" maxlength="6" id="pincode" name="pincode" placeholder="Enter Pincode">
									</div>
								</div>
								<div class="d-flex justify-content-between gap-3 mb-3">
									<div class="col-md-6">
										<label class="contactManagementLabel" for="email">Email Id *</label>
										<input class="contactManagementInput py-1 mt-1" type="email" id="email" name="email" placeholder="Enter Email Id" autocomplete="email">
									</div>
									<div class="col-md-6">
										<label class="contactManagementLabel" for="phone">Phone number *</label>
										<input class="contactManagementInput py-1 mt-1" type="text" maxlength="10" id="phone" name="phone" placeholder="Enter Phone number" autocomplete="tel">
									</div>
								</div>
							</div>
							<div class="modal-footer d-flex justify-content-around border-top-0">
								<button type="button" class="btn text-white bg-customDarkBlue rounded-pill py-1 px-4" data-bs-dismiss="modal">CLOSE</button>
								<button type="submit" class="btn btn-primary rounded-pill py-1 px-4" id="submitBtn" name="submitBtn">SUBMIT</button>
							</div>
						</form>
					</div>
					<div class="contactImageEnlarged d-flex align-items-center justify-content-end p-4">
						<img src="./assets/profilePictures/demo-profilepicture.png" alt="Contact Image Enlarged">
					</div>
				</div>
			</div>
		</div>
		<script src="./js/bootstrap.bundle.min.js"></script>
		<script>
			function logOut() {
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
		</script>
    </body>
</html>
