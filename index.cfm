<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Log In - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/login.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
		<script src="./js/jquery-3.7.1.min.js"></script>
    </head>

    <body>
        <header class="header d-flex align-items-center justify-content-between fixed-top px-5">
            <a class="d-flex align-items-center text-decoration-none" href="#">
                <img class="logo" src="./assets/images/logo.png" alt="Logo Image">
                <div class="text-white">ADDRESS BOOK</div>
            </a>
            <nav class="d-flex align-items-center gap-4">
                <a class="text-white text-decoration-none" href="signup.cfm">
                    <i class="fa-solid fa-user"></i>
                    Sign Up
                </a>
                <a class="text-white text-decoration-none" href="#">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    Login
                </a>
            </nav>
        </header>

        <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
            <div id="submitMsgSection" class="text-danger p-2"></div>
            <div class="row shadow-lg border-0 rounded-4 w-50">
                    <div class="leftSection col-md-4 d-flex align-items-center justify-content-center rounded-start-4">
                        <img class="logoLarge" src="./assets/images/logo.png" alt="Address Book Logo">
                    </div>
                    <div class="rightSection bg-white col-md-8 p-4 rounded-end-4">
                        <div class="text-center mb-4">
                            <h3 class="fw-normal mt-3">LOGIN</h3>
                        </div>
                        <form id="loginForm" name="loginForm" method="post">
                            <div class="mb-3">
                                <input type="text" class="inputBox" id="username" name="username" placeholder="Username" autocomplete="username">
                            </div>
                            <div class="mb-3">
                                <input type="password" class="inputBox" id="password" name="password" placeholder="Password">
                            </div>
                            <button type="submit" id="loginBtn" name="loginBtn" class="btn text-primary border-primary w-100 rounded-pill" disabled>LOGIN</button>
                            <div class="text-center my-3">Or Sign In Using</div>
                            <div class="d-flex justify-content-center gap-3">
                                <button type="button" class="btn btn-primary rounded-circle">
                                    <i class="fab fa-facebook-f"></i>
                                </button>
                                <button type="button" class="btn btn-danger rounded-circle">
                                    <i class="fab fa-google"></i>
                                </button>
                            </div>
                        </form>
                        <div class="text-center mt-3">
                            Don't have an account? <a class="text-decoration-none" href="signup.cfm">Register Here</a>
                        </div>
                    </div>
            </div>
        </div>
		<script src="./js/bootstrap.bundle.min.js"></script>
        <script>
            function toggleBtnState() {
                const username = $("#username").val();
                const loginBtn = $("#loginBtn");

                if (username.trim() == "") {
                    loginBtn.prop("disabled", true);
                }
                else {
                    loginBtn.prop("disabled", false);
                }
            }

            $("#username").change(toggleBtnState);

            $("#loginForm").submit(function(event) {
                event.preventDefault();
                const email = $("#email").val();
                const password =  $("#password").val();
                const submitMsgSection = $("#submitMsgSection");
                const thisForm = $(this)[0];
                const formData = new FormData(thisForm);
                $.ajax({
                    type: "POST",
                    url: "./components/addressbook.cfc?method=logIn",
                    data: formData,
                    enctype: 'multipart/form-data',
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        const responseJSON = JSON.parse(response);
                        if (responseJSON.statusCode === 0) {
                            thisForm.reset();
                            window.location.href = "home.cfm";
                        }
                        else {
                            submitMsgSection.text(responseJSON.message);
                        }

                    },
                    error: function (xhr, ajaxOptions, thrownError) {
                        submitMsgSection.text("We encountered an error! Error details are: " + thrownError);
                    }
                });
            });
        </script>
    </body>
</html>