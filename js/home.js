function logOut() {
	if (confirm("Confirm logout")) {
		const submitMsgSection = $("#submitMsgSection");

		$.ajax({
			type: "POST",
			url: "./components/addressbook.cfc?method=logOut",
			success: function(response) {
				const responseJSON = JSON.parse(response);
				if (responseJSON.statusCode === 200) {
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
			const { title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone } = responseJSON;
			const convertedDOB = new Date(dob);
			const formattedDOB = new Date(dob).toLocaleDateString('en-US', {
				year: "numeric",
				month: "long",
				day: "numeric",
			})

			viewContactName.text(`${title} ${firstname} ${lastname}`);
			viewContactGender.text(gender);
			viewContactDOB.text(formattedDOB);
			viewContactAddress.text(`${address}, ${street}, ${district}, ${state}, ${country}`);
			viewContactPincode.text(pincode);
			viewContactEmail.text(email);
			viewContactPhone.text(phone);
			viewContactPicture.attr("src", `./assets/contactImages/${contactpicture}`);
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
				if (responseJSON.statusCode === 200) {
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
			const { contactid, title, firstname, lastname, gender, dob, contactpicture, address, street, district, state, country, pincode, email, phone } = responseJSON;
			const formattedDOB = new Date(dob).toLocaleDateString('fr-ca')

			$("#editContactId").val(contactid);
			$("#editContactTitle").val(title);
			$("#editContactFirstname").val(firstname);
			$("#editContactLastname").val(lastname);
			$("#editContactGender").val(gender);
			$("#editContactDOB").val(formattedDOB);
			$("#editContactImage").val("");
			$("#editContactPicture").attr("src", `./assets/contactImages/${contactpicture}`);
			$("#editContactAddress").val(address);
			$("#editContactStreet").val(street);
			$("#editContactDistrict").val(district);
			$("#editContactState").val(state);
			$("#editContactCountry").val(country);
			$("#editContactPincode").val(pincode);
			$("#editContactEmail").val(email);
			$("#editContactPhone").val(phone);
			$('#contactManagementModal').modal('show');
		}
	});
}

function validateContactForm() {
    const fields = [
        { id: "editContactTitle", errorId: "titleError", message: "Please select one option", regex: null },
        { id: "editContactFirstname", errorId: "firstNameError", message: "Please enter your First name", regex: /^[a-zA-Z ]+$/ },
        { id: "editContactLastname", errorId: "lastNameError", message: "Please enter your Last name", regex: /^[a-zA-Z ]+$/ },
        { id: "editContactGender", errorId: "genderError", message: "Please select one option", regex: null },
        { id: "editContactDOB", errorId: "dobError", message: "Please select your DOB", regex: null },
        { id: "editContactAddress", errorId: "addressError", message: "Please enter your address", regex: null },
        { id: "editContactStreet", errorId: "streetError", message: "Please enter your street", regex: null },
        { id: "editContactDistrict", errorId: "districtError", message: "Please enter your district", regex: null },
        { id: "editContactState", errorId: "stateError", message: "Please enter your state", regex: null },
        { id: "editContactCountry", errorId: "countryError", message: "Please enter your country", regex: null },
        { id: "editContactPincode", errorId: "pincodeError", message: "Please enter your pin", regex: /^\d{6}$/, customError: "Pincode should be six digits" },
        { id: "editContactEmail", errorId: "emailError", message: "Please enter your mail", regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/ },
        { id: "editContactPhone", errorId: "phoneError", message: "Please enter your contact number", regex: /^\d{10}$/, customError: "Phone number should be 10 characters long and contain only digits" },
    ];

    let valid = true;

    fields.forEach(field => {
        const value = $(`#${field.id}`).val().trim();

        if (value === "" || (field.regex && !field.regex.test(value))) {
            const errorMessage = value === "" ? field.message : field.customError || field.message;
            $(`#${field.errorId}`).text(errorMessage);
            valid = false;
        } else {
            $(`#${field.errorId}`).text("");
        }
    });

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
			if (responseJSON.statusCode === 200) {
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

$(document).ready(function(){
	$("#scheduleBdayEmailBtn").show();
	$("#diableBdayEmailBtn").hide();

	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=getTaskStatus",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.taskExists) {
				$("#scheduleBdayEmailBtn").hide();
				$("#diableBdayEmailBtn").show();
			}
		}
	});

	// Enable custom tooltip styling using bootstrap
	$('[data-bs-toggle="tooltip"]').tooltip();

	// Set max of dob input to current date
	$("#editContactDOB").attr({
		"max": new Date().toLocaleDateString('fr-ca')
	})
});

function scheduleBdayEmails() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=scheduleBdayEmails",
		success: function() {
			$("#scheduleBdayEmailBtn").hide();
			$("#diableBdayEmailBtn").show();
		}
	});
}

function disableBdayEmails() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=disableBdayEmails",
		success: function() {
			$("#scheduleBdayEmailBtn").show();
			$("#diableBdayEmailBtn").hide();
		}
	});
}
