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
	$(".error").text("");
	$("#contactManagement")[0].reset();
	$("#editContactId").val("");
	$("#contactManagementMsgSection").text("");
	$('#contactManagementModal').modal('show');
}

function editContact(event) {
	$("#contactManagementHeading").text("EDIT CONTACT");
	$(".error").text("");

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
    let title = $("#editContactTitle").val();
    let firstname = $("#editContactFirstname").val();
    let lastname = $("#editContactLastname").val();
    let gender = $("#editContactGender").val();
    let dob = $("#editContactDOB").val();
    let address = $("#editContactAddress").val();
    let street = $("#editContactStreet").val();
    let district = $("#editContactDistrict").val();
    let state = $("#editContactState").val();
    let country = $("#editContactCountry").val();
    let pin = $("#editContactPincode").val();
    let mail = $("#editContactEmail").val();
    let phone = $("#editContactPhone").val();
    let valid = true;

    if(title == ""){
        $("#titleError").text("Please select one option");
        valid = false;
    }
    else{
        $("#titleError").text("");
    }

    if(firstname == "" || !/^[a-zA-Z ]+$/.test(firstname)){
        $("#firstNameError").text("Please enter your First name");
        valid = false;
    }
    else{
        $("#firstNameError").text("");
    }

    if(lastname == "" || !/^[a-zA-Z ]+$/.test(lastname)){
        $("#lastNameError").text("Please enter your Last name");
        valid = false;
    }
    else{
        $("#lastNameError").text("");
    }

    if(gender == ""){
        $("#genderError").text("Please select one option");
        valid = false;
    }
    else{
        $("#genderError").text("");
    }

    if(dob == ""){
        $("#dobError").text("Please select your DOB");
        valid = false;
    }
    else{
        $("#dobError").text("");
    }

    if(address == ""){
        $("#addressError").text("Please enter your address");
        valid = false;
    }
    else{
        $("#addressError").text("");
    }

    if(street == ""){
        $("#streetError").text("Please enter your street");
        valid = false;
    }
    else{
        $("#streetError").text("");
    }

    if(pin == ""){
        $("#pincodeError").text("Please enter your pin");
        valid = false;
    }
	else if (!/^\d{6}$/.test(pin)) {
        $("#pincodeError").text("Pincode should be six digits");
        valid = false;
	}
    else{
        $("#pincodeError").text("");
    }

    if(district == ""){
        $("#districtError").text("Please enter your district");
        valid = false;
    }
    else{
        $("#districtError").text("");
    }

    if(state == ""){
        $("#stateError").text("Please enter your state");
        valid = false;
    }
    else{
        $("#stateError").text("");
    }

    if(country == ""){
        $("#countryError").text("Please enter your country");
        valid = false;
    }
    else{
        $("#countryError").text("");
    }

    if(mail == "" || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(mail)){
        $("#emailError").text("Please enter your mail");
        valid = false;
    }
    else{
        $("#emailError").text("");
    }

    if(phone == ""){
        $("#phoneError").text("Please enter your contact number");
        valid = false;
    }
    else if(!/^\d{10}$/.test(phone)){
        $("#phoneError").text("Phone number should be 10 characters long and contain only digits");
        valid = false;
    }
    else{
        $("#phoneError").text("");
    }
    return valid;
}

$("#contactManagement").submit(function(event) {
	const contactManagementMsgSection = $("#contactManagementMsgSection");
	const thisForm = $(this)[0];
	const formData = new FormData(thisForm);

	event.preventDefault();
	$("#contactManagementMsgSection").text("");
	if (!validateContactForm()) return;
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