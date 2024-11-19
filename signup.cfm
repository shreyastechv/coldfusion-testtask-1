<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/signup.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
        <script src="../js/jquery-3.7.1.min.js"></script>
    </head>

    <body>
        <header class="header d-flex align-items-center justify-content-between fixed-top px-5">
            <a class="d-flex align-items-center text-decoration-none" href="##">
                <img class="logo" src="./assets/images/logo.png" alt="Logo Image">
                <div class="text-white">ADDRESS BOOK</div>
            </a>
            <nav class="d-flex align-items-center gap-4">
                <a class="text-white text-decoration-none" href="signup.cfm">
                    <i class="fa-solid fa-user"></i>
                    Sign Up
                </a>
                <a class="text-white text-decoration-none" href="login.cfm">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    Login
                </a>
            </nav>
        </header>

        <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
            <div id="submitMsgSection" class="p-2"></div>
            <div class="row shadow-lg border-0 rounded-4 w-75">
                    <div class="leftSection col-md-4 d-flex align-items-center justify-content-center rounded-start-4">
                        <img class="logoLarge" src="./assets/images/logo.png" alt="Address Book Logo">
                    </div>
                    <div class="rightSection bg-white col-md-8 p-4 rounded-end-4">
                        <div class="text-center mb-2">
                            <h3 class="fw-normal">SIGN UP</h3>
                        </div>
                        <form id="signupForm" name="signupForm" method="post" enctype="multipart/form-data">
                            <div class="mb-3">
                                <input type="text" class="inputBox" id="fullname" name="fullname" placeholder="Full Name">
                                <div class="text-danger" id="fullnameError"></div>
                            </div>
                            <div class="mb-3">
                                <input type="email" class="inputBox" id="email" name="email" placeholder="Email ID" autocomplete="username">
                                <div class="text-danger" id="emailError"></div>
                            </div>
                            <div class="mb-3">
                                <input type="text" class="inputBox" id="username" name="username" placeholder="Username" autocomplete="username">
                                <div class="text-danger" id="usernameError"></div>
                            </div>
                            <div class="mb-3">
                                <input type="password" class="inputBox" id="password" name="password" placeholder="Password">
                                <div class="text-danger" id="passwordError"></div>
                            </div>
                            <div class="mb-3">
                                <input type="password" class="inputBox" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password">
                                <div class="text-danger" id="confirmPasswordError"></div>
                            </div>
                            <div class="mb-3">
                                <label for="profilePicture">Profile picture: </label>
                                <input type="file" id="profilePicture" name="profilePicture" accept="image/*">
                                <div class="text-danger" id="profilePictureError"></div>
                            </div>
                            <button type="submit" name="submitBtn" id="submitBtn" class="btn text-primary border-primary w-100 rounded-pill">REGISTER</button>
                        </form>
                        <div class="text-center mt-3">
                            Already have an account? <a class="text-decoration-none" href="login.cfm">Login</a>
                        </div>
                    </div>
            </div>
        </div>
		<script src="./js/bootstrap.bundle.min.js"></script>
        <script>
            const signupForm = $("#signupForm");

            signupForm.submit(function(event) {
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
                const leftSection = $("#leftSection");
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
                if (username == "") {
                    usernameError.text("This field is requied!");
                    valid = false;
                }
                else if (!/^[a-z0-9_.-]+$/.test(username)) {
                    usernameError.text("Usernames can only use letters, numbers, hyphens, underscores, and periods.");
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
                    const thisForm = $(this)[0];
                    const formData = new FormData(thisForm);
                    // formData.append("profilePicture", $("#profilePicture")[0].files[0]);
                    $.ajax({
                        type: "POST",
                        url: "./components/addressbook.cfc?method=signUp",
                        data: formData,
                        enctype: 'multipart/form-data',
                        processData: false,
                        contentType: false,
                        success: function(response) {
                            console.log(JSON.parse(response));
                            submitMsgSection.css("color", "green");
                            submitMsgSection.html("Account created successfully. <a class='text-decoration-none text-primary' href='index.cfm'>Login</a> to continue.");
                            thisForm.reset();
                        },
                        error: function (xhr, ajaxOptions, thrownError) {
                            submitMsgSection.css("color", "red");
                            submitMsgSection.text("We encountered an error! Error details are: " + thrownError);
                        }
                    });
                }
                else {
                    // event.preventDefault();
                }
            });
        </script>
    </body>
</html>
