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
		roleIdsToInsert: currentContactRoles.filter(element => !previousContactRoles.includes(element)).join(","),
		roleIdsToDelete: previousContactRoles.filter(element => !currentContactRoles.includes(element)).join(",")
	};
	const contactData = new FormData();

	Object.keys(contactDataObj).forEach(key => {
		contactData.append(key, contactDataObj[key]);
	});

	$("#contactManagementMsgSection").text("");
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
					this.reset();
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

function createExcel() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=createExcel",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			downloadURI(`./assets/spreadsheets/${responseJSON.data}`, responseJSON.data);
		}
	});
}

function createPdf() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=createPdf",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			downloadURI(`./assets/pdfs/${responseJSON.data}`, responseJSON.data);
		}
	});
}

function loadDataFromContactsArray(contactsArray) {
	const tableBody = document.getElementById('contactTableBody');
	tableBody.innerHTML = ''; // Clear any existing rows

	contactsArray.forEach(contact => {
		const row = document.createElement('tr');

		// Create and append image cell
		const imageCell = document.createElement('td');
		const img = document.createElement('img');
		img.classList.add('contactImage', 'p-2', 'rounded-4');
		img.src = `./assets/contactImages/${contact[3]}`;
		img.alt = 'Contact Image';
		imageCell.appendChild(img);
		row.appendChild(imageCell);

		// Create and append name cell
		const nameCell = document.createElement('td');
		nameCell.textContent = `${contact[1]} ${contact[2]}`;
		row.appendChild(nameCell);

		// Create and append email cell
		const emailCell = document.createElement('td');
		emailCell.textContent = contact[4];
		row.appendChild(emailCell);

		// Create and append phone cell
		const phoneCell = document.createElement('td');
		phoneCell.textContent = contact[5];
		row.appendChild(phoneCell);

		// Create and append Edit button cell
		const editButtonCell = document.createElement('td');
		editButtonCell.classList.add('d-print-none');
		const editButton = document.createElement('button');
		editButton.classList.add('actionBtn', 'btn', 'btn-outline-primary', 'rounded-pill', 'px-3');
		editButton.value = contact[0];
		editButton.setAttribute('onclick', 'editContact(event)');
		editButton.innerHTML = `
		<span class="d-none d-lg-inline pe-none">EDIT</span>
		<i class="fa-solid fa-pen-to-square d-lg-none pe-none"></i>
		`;
		editButtonCell.appendChild(editButton);
		row.appendChild(editButtonCell);

		// Create and append Delete button cell
		const deleteButtonCell = document.createElement('td');
		deleteButtonCell.classList.add('d-print-none');
		const deleteButton = document.createElement('button');
		deleteButton.classList.add('actionBtn', 'btn', 'btn-outline-danger', 'rounded-pill', 'px-3');
		deleteButton.value = contact[0];
		deleteButton.setAttribute('onclick', 'deleteContact(event)');
		deleteButton.innerHTML = `
		<span class="d-none d-lg-inline pe-none">DELETE</span>
		<i class="fa-solid fa-trash d-lg-none pe-none"></i>
		`;
		deleteButtonCell.appendChild(deleteButton);
		row.appendChild(deleteButtonCell);

		// Create and append View button cell
		const viewButtonCell = document.createElement('td');
		viewButtonCell.classList.add('d-print-none');
		const viewButton = document.createElement('button');
		viewButton.classList.add('actionBtn', 'btn', 'btn-outline-info', 'rounded-pill', 'px-3');
		viewButton.value = contact[0];
		viewButton.setAttribute('onclick', 'viewContact(event)');
		viewButton.innerHTML = `
		<span class="d-none d-lg-inline pe-none">VIEW</span>
		<i class="fa-solid fa-eye d-lg-none pe-none"></i>
		`;
		viewButtonCell.appendChild(viewButton);
		row.appendChild(viewButtonCell);

		// Append the row to the table body
		tableBody.appendChild(row);
	});
}

function loadHomePageData() {
	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=getContacts",
		success: function(response) {
			const responseJSON = JSON.parse(response);
			loadDataFromContactsArray(responseJSON.DATA);
		}
	});
}

$(document).ready(function(){
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

	loadHomePageData();
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
