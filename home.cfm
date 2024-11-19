<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Log In - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/home.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
    </head>

    <body>
        <header class="header d-flex align-items-center justify-content-between fixed-top px-5">
            <a class="d-flex align-items-center text-decoration-none" href="##">
                <img class="logo" src="./assets/images/logo.png" alt="Logo Image">
                <div class="text-white">ADDRESS BOOK</div>
            </a>
            <nav class="d-flex align-items-center gap-4">
                <a class="text-white text-decoration-none" href="##">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    Logout
                </a>
            </nav>
        </header>

		<div class="container-fluid px-5 py-2 my-5">
			<div class="px-3 py-2 mx-auto w-100 bg-white rounded-1 d-flex align-items-center justify-content-end">
				<a href="##" onclick="createPdf()" class="mx-2">
					<img class="toolbarIcon p-1" src="./assets/images/pdficon.png" alt="PDF Icon">
				</a>
				<a href="##" onclick="createExcel()" class="mx-2">
					<img class="toolbarIcon" src="./assets/images/excelicon.png" alt="Excel Icon">
				</a>
				<a href="##" onclick="printPage()" class="mx-2">
					<img class="toolbarIcon p-1" src="./assets/images/printericon.png" alt="Printer Icon">
				</a>
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
									<button class="actionBtn btn btn-outline-primary rounded-pill px-4">EDIT</button>
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
								<h5>CONTACT DETAILS</h5>
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
						<img src="./assets/profilePictures/image_2021_05_28T13_35_32_831Z.png" alt="Contact Image Enlarged">
					</div>
				</div>
			</div>
		</div>
		<script src="./js/bootstrap.bundle.min.js"></script>
    </body>
</html>
