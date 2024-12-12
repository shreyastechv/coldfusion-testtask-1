$("#signupForm").submit(function(event) {
	event.preventDefault();
	const fullname = $("#fullname").val();
	const fullnameError = $("#fullnameError");
	const email = $("#email").val();
	const emailError = $("#emailError");
	const username = $("#username").val();
	const usernameError = $("#usernameError");
	const password = $("#password").val();
	const passwordError = $("#passwordError");
	const confirmPassword = $("#confirmPassword").val();
	const confirmPasswordError = $("#confirmPasswordError");
	const profilePicture = $("#profilePicture");
	const profilePictureError = $("#profilePictureError");
	const submitMsgSection = $("#submitMsgSection");
	let valid = true;

	// Full name validation
	if (fullname == "") {
		fullnameError.text("This field is requied!");
		valid = false;
	}
	else if(/\d/.test(fullname)) {
		fullnameError.text("Name cannot contain a number");
		valid = false;
	}
	else {
		fullnameError.text("");
	}

	//Email validation
	const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (email == "") {
		emailError.text("This field is requied!");
		valid = false;
	}
	else if(!emailPattern.test(email)) {
		emailError.text("Email not valid!");
		valid = false;
	}
	else {
		emailError.text("");
	}

	// Username validation
	const usernamePattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
	if (username == "") {
		usernameError.text("This field is requied!");
		valid = false;
	}
	else if(!usernamePattern.test(username)) {
		usernameError.text("Only emails can be used as username.");
		valid = false;
	}
	else {
		usernameError.text("");
	}

	// Password validation
	if (password == "") {
		passwordError.text("This field is requied!");
		valid = false;
	}
	else if(password.length < 8) {
		passwordError.text("There should be atleast 8 characters");
		valid = false;
	}
	else if(password == password.toUpperCase()) {
		passwordError.text("There shoule be atleast atleast one lowercase letter");
		valid = false;
	}
	else if(password == password.toLowerCase()) {
		passwordError.text("There shoule be atleast one uppercase letter");
		valid = false;
	}
	else if(!/\d/.test(password)) {
		passwordError.text("There shoule be atleast one digit");
		valid = false;
	}
	else if(!/[@$!%*?&^]/.test(password)) {
		passwordError.text("There shoule be atleast one special character (@$!%*?&^)");
		valid = false;
	}
	else {
		passwordError.text("");
	}

	// Confirm password validation
	if (confirmPassword == "") {
		confirmPasswordError.text("This field is requied!");
		valid = false;
	}
	else if (confirmPassword !== password) {
		confirmPasswordError.text("Passwords don't match");
		valid = false;
	}
	else {
		confirmPasswordError.text("");
	}

	// Image type validation
	if (profilePicture.val() == "") {
		profilePictureError.text("This field is requied!");
		valid = false;
	} else if(profilePicture[0].files[0].type.split('/')[0] !== 'image'){
		profilePictureError.text("Only images are allowed");
		valid = false;
	}
	else {
		profilePictureError.text("");
	}

	if (valid) {
		const formData = new FormData(this);
		$.ajax({
			type: "POST",
			url: "./components/addressbook.cfc?method=signUp",
			data: formData,
			enctype: 'multipart/form-data',
			processData: false,
			contentType: false,
			success: function(response) {
				const responseJSON = JSON.parse(response);
				if (responseJSON.statusCode === 200) {
					submitMsgSection.css("color", "green");
					submitMsgSection.html("Account created successfully. <a class='text-decoration-none text-primary' href='index.cfm'>Login</a> to continue.");
					this.reset();
				}
				else {
					submitMsgSection.css("color", "red");
					submitMsgSection.text(responseJSON.message);
				}
			},
			error: function (xhr, ajaxOptions, thrownError) {
				submitMsgSection.css("color", "red");
				submitMsgSection.text("We encountered an error! Error details are: " + thrownError);
			}
		});
	}
});
