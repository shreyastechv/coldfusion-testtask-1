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
				<a href="#" onclick="createPdf()" class="mx-2">
					<img class="toolbarIcon p-1" src="./assets/images/pdficon.png" alt="PDF Icon">
				</a>
				<a href="#" onclick="createExcel()" class="mx-2">
					<img class="toolbarIcon" src="./assets/images/excelicon.png" alt="Excel Icon">
				</a>
				<a href="#" onclick="printPage()" class="mx-2">
					<img class="toolbarIcon" src="./assets/images/printericon.png" alt="Printer Icon">
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
									<button class="actionBtn btn btn-outline-info rounded-pill px-3">VIEW</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
		<script src="./js/bootstrap.bundle.min.js"></script>
    </body>
</html>
