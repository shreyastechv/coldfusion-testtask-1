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
	resetContactFormErrors();
	$("#contactManagement")[0].reset();
	$("#editContactId").val("");
	$("#contactManagementMsgSection").text("");
	$('#contactManagementModal').modal('show');
}

function editContact(event) {
	$("#contactManagementHeading").text("EDIT CONTACT");
	resetContactFormErrors();

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
			$("#editContactImage").val("");
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

function validateContactForm(){
    let title = document.forms["contactManagement"]["editContactTitle"].value;
    let firstname = document.forms["contactManagement"]["editContactFirstname"].value;
    let lastname = document.forms["contactManagement"]["editContactLastname"].value;
    let gender = document.forms["contactManagement"]["editContactGender"].value;
    let dob = document.forms["contactManagement"]["editContactDOB"].value;
    let img = document.forms["contactManagement"]["editContactImage"].value;
    let address = document.forms["contactManagement"]["editContactAddress"].value;
    let street = document.forms["contactManagement"]["editContactStreet"].value;
    let district = document.forms["contactManagement"]["editContactDistrict"].value;
    let state = document.forms["contactManagement"]["editContactState"].value;
    let country = document.forms["contactManagement"]["editContactCountry"].value;
    let pin = document.forms["contactManagement"]["editContactPincode"].value;
    let mail = document.forms["contactManagement"]["editContactEmail"].value;
    let phone = document.forms["contactManagement"]["editContactPhone"].value;
    let valid = true;

    if(title == ""){
        document.getElementById("titleError").textContent = "Please select one option";
        valid = false;
    }
    else{
        document.getElementById("titleError").textContent = "";
    }

    if(firstname == "" || !/^[a-zA-Z ]+$/.test(firstname)){
        document.getElementById("firstNameError").textContent = "Please enter your First name";
        valid = false;
    }
    else{
        document.getElementById("firstNameError").textContent = "";
    }

    if(lastname == "" || !/^[a-zA-Z ]+$/.test(lastname)){
        document.getElementById("lastNameError").textContent = "Please enter your Last name";
        valid = false;
    }
    else{
        document.getElementById("lastNameError").textContent = "";
    }

    if(gender == ""){
        document.getElementById("genderError").textContent = "Please select one option";
        valid = false;
    }
    else{
        document.getElementById("genderError").textContent = "";
    }

    if(dob == ""){
        document.getElementById("dobError").textContent = "Please select your DOB";
        valid = false;
    }
    else{
        document.getElementById("dobError").textContent = "";
    }

    if(img == ""){
        document.getElementById("contactImageError").textContent = "Please select image file for profile pic";
        valid = false;
    }
    else{
        document.getElementById("contactImageError").textContent = "";
    }

    if(address == ""){
        document.getElementById("addressError").textContent = "Please enter your address";
        valid = false;
    }
    else{
        document.getElementById("addressError").textContent = "";
    }

    if(street == ""){
        document.getElementById("streetError").textContent = "Please enter your street";
        valid = false;
    }
    else{
        document.getElementById("streetError").textContent = "";
    }

    if(pin == ""){
        document.getElementById("pincodeError").textContent = "Please enter your pin";
        valid = false;
    }
    else{
        document.getElementById("pincodeError").textContent = "";
    }

    if(district == ""){
        document.getElementById("districtError").textContent = "Please enter your district";
        valid = false;
    }
    else{
        document.getElementById("districtError").textContent = "";
    }

    if(state == ""){
        document.getElementById("stateError").textContent = "Please enter your state";
        valid = false;
    }
    else{
        document.getElementById("stateError").textContent = "";
    }

    if(country == ""){
        document.getElementById("countryError").textContent = "Please enter your country";
        valid = false;
    }
    else{
        document.getElementById("countryError").textContent = "";
    }

    if(mail == "" || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(mail)){
        document.getElementById("emailError").textContent = "Please enter your mail";
        valid = false;
    }
    else{
        document.getElementById("emailError").textContent = "";
    }

    if(phone == "" || !/^\d{10}$/.test(phone)){
        document.getElementById("phoneError").textContent = "Please enter your contact number";
        valid = false;
    }
    else{
        document.getElementById("phoneError").textContent = "";
    }
    return valid;
}

function resetContactFormErrors() {
	document.getElementById("titleError").textContent = "";
	document.getElementById("firstNameError").textContent = "";
	document.getElementById("lastNameError").textContent = "";
	document.getElementById("genderError").textContent = "";
	document.getElementById("dobError").textContent = "";
	document.getElementById("contactImageError").textContent = "";
	document.getElementById("addressError").textContent = "";
	document.getElementById("streetError").textContent = "";
	document.getElementById("pincodeError").textContent = "";
	document.getElementById("districtError").textContent = "";
	document.getElementById("stateError").textContent = "";
	document.getElementById("countryError").textContent = "";
	document.getElementById("emailError").textContent = "";
	document.getElementById("phoneError").textContent = "";
}

$("#contactManagement").submit(function(event) {
	event.preventDefault();
	if (!validateContactForm()) {
		return;
	}
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

function downloadURI(uri, name) {
	var link = document.createElement("a");
	link.download = name;
	link.href = uri;
	link.click();
	link.remove();
}

function createExcel() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=createExcel",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			downloadURI(`./assets/spreadsheets/${responseJSON.data}`, "contact-details.xlsx");
		}
	});
}

function createPdf() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=createPdf",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			downloadURI(`./assets/pdfs/${responseJSON.data}`, "contact-details.pdf");
		}
	});
}