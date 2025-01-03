function logOut() {
	if (confirm("Confirm logout")) {

		$.ajax({
			type: "POST",
			url: "./components/addressbook.cfc?method=logOut",
			success: function(response) {
				const responseJSON = JSON.parse(response);
				if (responseJSON.statusCode === 200) {
					location.reload();
				}
				else {
					alert(responseJSON.message);
				}
			},
			error: function () {
				alert("Sorry, Unable to logout!");
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
	const viewContactRoles = $("#viewContactRoles");

	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=getContactById",
		data: { contactId: event.target.value },
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const { title, firstname, lastname, gender, dob, contactPicture, address, street, district, state, country, pincode, email, phone, roleNames } = responseJSON;
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
			viewContactPicture.attr("src", `./assets/contactImages/${contactPicture}`);
			viewContactRoles.text(roleNames);
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
					event.target.parentNode.parentNode.remove();
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
	$("#editContactRole").attr("defaultValue", []);
	$('#contactManagementModal').modal('show');
}

function editContact(event) {
	$("#contactManagementHeading").text("EDIT CONTACT");
	$(".error").text("");
	$("#contactManagementMsgSection").text("");

	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=getContactById",
		data: { contactId: event.target.value },
		success: function(response) {
			const responseJSON = JSON.parse(response);
			const { contactid, title, firstname, lastname, gender, dob, contactPicture, address, street, district, state, country, pincode, email, phone, roleIds, roleNames } = responseJSON;
			const formattedDOB = new Date(dob).toLocaleDateString('fr-ca');

			$("#editContactId").val(contactid);
			$("#editContactTitle").val(title);
			$("#editContactFirstName").val(firstname);
			$("#editContactLastName").val(lastname);
			$("#editContactGender").val(gender);
			$("#editContactDOB").val(formattedDOB);
			$("#editContactImage").val("");
			$("#editContactPicture").attr("src", `./assets/contactImages/${contactPicture}`);
			$("#editContactAddress").val(address);
			$("#editContactStreet").val(street);
			$("#editContactDistrict").val(district);
			$("#editContactState").val(state);
			$("#editContactCountry").val(country);
			$("#editContactPincode").val(pincode);
			$("#editContactEmail").val(email);
			$("#editContactPhone").val(phone);
			$("#editContactRole").val(roleIds);
			$("#editContactRole").attr("defaultValue", roleIds);
			$('#contactManagementModal').modal('show');
		}
	});
}

function validateContactForm() {
    const fields = [
        { id: "editContactTitle", errorId: "titleError", message: "Please select one option", regex: null },
        { id: "editContactFirstName", errorId: "firstNameError", message: "Please enter your First name", regex: /^[a-zA-Z ]+$/ },
        { id: "editContactLastName", errorId: "lastNameError", message: "Please enter your Last name", regex: /^[a-zA-Z ]+$/ },
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
        { id: "editContactRole", errorId: "roleError", message: "Please select atleast one user role", regex: null },
    ];

    let valid = true;

    fields.forEach(field => {
		const fieldValue = $(`#${field.id}`).val();
        const value = Array.isArray(fieldValue) ? fieldValue.toString() : fieldValue.trim();

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
	event.preventDefault();
	const thisForm = this;
	const contactManagementMsgSection = $("#contactManagementMsgSection");
	const currentContactRoles = $("#editContactRole").val();
	const previousContactRoles = $("#editContactRole").attr("defaultValue").split(",");
	const contactDataObj = {
		contactId: $("#editContactId").val(),
        contactTitle: $("#editContactTitle").val(),
        contactFirstName: $("#editContactFirstName").val(),
        contactLastName: $("#editContactLastName").val(),
        contactGender: $("#editContactGender").val(),
        contactDOB: $("#editContactDOB").val(),
		contactImage: $("#editContactImage")[0].files[0] || "",
        contactAddress: $("#editContactAddress").val(),
        contactStreet: $("#editContactStreet").val(),
        contactDistrict: $("#editContactDistrict").val(),
        contactState: $("#editContactState").val(),
        contactCountry: $("#editContactCountry").val(),
        contactPincode: $("#editContactPincode").val(),
        contactEmail: $("#editContactEmail").val(),
        contactPhone: $("#editContactPhone").val(),
		roleIdsToInsert: currentContactRoles.filter(element => !previousContactRoles.includes(trim(element))).join(","),
		roleIdsToDelete: previousContactRoles.filter(element => !currentContactRoles.includes(trim(element))).join(",")
	};

	// Convert object to formData
	const contactData = new FormData();
	Object.keys(contactDataObj).forEach(key => {
		contactData.append(key, contactDataObj[key]);
	});

	contactManagementMsgSection.text("");
	if (!validateContactForm()) return;
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=modifyContacts",
		data: contactData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.statusCode === 200) {
				contactManagementMsgSection.css("color", "green");
				loadHomePageData();
				if ($("#editContactId").val() === "") {
					thisForm.reset();
				}
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

function createContactsFile(file) {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=createContactsFile",
		data: {
			file: file
		},
		success: function(response) {
			const fileName = JSON.parse(response);
			switch(file) {
				case "pdf":
					downloadURI(`./assets/pdfs/${fileName}`, `${fileName}`);
					break;
				case "excel":
					downloadURI(`./assets/spreadsheets/${fileName}`, `${fileName}`);
				  	break;
				case "excelTemplate":
					downloadURI(`./assets/spreadsheets/${fileName}`, "Plain_Template.xlsx");
				  	break;
				case "excelTemplateWithData":
					downloadURI(`./assets/spreadsheets/${fileName}`, "Template_with_data.xlsx");
					break;
			}
		}
	});
}

function loadHomePageData() {
	$('#mainContent').load(document.URL +  ' #mainContent');
}

$(document).ready(function(){
	// Set bday email schedule button state
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=getTaskStatus",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.taskExists) {
				$("#scheduleBdayEmailBtn").text("DISABLE BDAY MAILS");
				$("#scheduleBdayEmailBtn").addClass("bg-danger");
				$("#scheduleBdayEmailBtn").removeClass("bg-secondary");
			}
			else {
				$("#scheduleBdayEmailBtn").text("SCHEDULE BDAY MAILS");
				$("#scheduleBdayEmailBtn").addClass("bg-secondary");
				$("#scheduleBdayEmailBtn").removeClass("bg-danger");
			}
		}
	});
});

function toggleBdayEmailSchedule() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=toggleBdayEmailSchedule",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.taskcurrentlyExists) {
				$("#scheduleBdayEmailBtn").text("DISABLE BDAY MAILS");
				$("#scheduleBdayEmailBtn").addClass("bg-danger");
				$("#scheduleBdayEmailBtn").removeClass("bg-secondary");
			}
			else {
				$("#scheduleBdayEmailBtn").text("SCHEDULE BDAY MAILS");
				$("#scheduleBdayEmailBtn").addClass("bg-secondary");
				$("#scheduleBdayEmailBtn").removeClass("bg-danger");
			}
		}
	});
}

// Excel upload submit function
$("#contactUpload").submit(function(event) {
	event.preventDefault();
	const thisForm = this;
	const contactUploadMsgSection = $("#contactUploadMsgSection");
	const uploadExcelInput = $("#uploadExcel");
	const uploadExcelError = $("#uploadExcelError");
	const contactData = new FormData(thisForm);

	$(".error").text("");

	if (uploadExcelInput.val() == "") {
		uploadExcelError.text("Select a file");
		return;
	}
	else if (uploadExcelInput[0].files[0].type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") {
		uploadExcelError.text("Only excel files are allowed");
		return;
	}

	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=uploadExcel",
		data: contactData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.statusCode === 200) {
				contactUploadMsgSection.css("color", "green");
				contactUploadMsgSection.text("Contacts Uploaded Successfully. Check the downloaded file for more details.");
			}
			else {
				contactUploadMsgSection.css("color", "red");
				contactUploadMsgSection.text("There were some errors. Check the downloaded file for more details.");
			}
			downloadURI(`./assets/spreadsheets/${responseJSON.fileName}`, `${responseJSON.fileName}`);
			loadHomePageData();
			thisForm.reset();
		}
	});
});