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
	$("#contactManagementMsgSection").text("");
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
