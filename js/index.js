function toggleBtnState() {
	const username = $("#username").val();
	const loginBtn = $("#loginBtn");

	if (username.trim() == "") {
		loginBtn.prop("disabled", true);
		loginBtn.attr("data-bs-original-title", "Enter your username");
	}
	else {
		loginBtn.prop("disabled", false);
		loginBtn.attr("data-bs-original-title", "");
	}
}

$("#username").keyup(toggleBtnState);

$("#loginForm").submit(function(event) {
	event.preventDefault();
	const submitMsgSection = $("#submitMsgSection");
	const formData = new FormData(this);

	$.ajax({
		type: "POST",
		url: "./components/addressbook.cfc?method=logIn",
		data: formData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			const responseJSON = JSON.parse(response);
			if (responseJSON.statusCode === 200) {
				location.reload();
			}
			else {
				submitMsgSection.text(responseJSON.message);
			}
		},
		error: function() {
			submitMsgSection.text("We encountered an error!");
		}
	});
});

$(document).ready(function(){
	// Enable custom tooltip styling using bootstrap
	$('[data-bs-toggle="tooltip"]').tooltip();
});