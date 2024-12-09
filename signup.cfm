<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up - Address Book</title>
		<link href="./css/bootstrap.min.css" rel="stylesheet">
		<link href="./css/signup.css" rel="stylesheet">
		<script src="./js/fontawesome.js"></script>
        <script src="./js/jquery-3.7.1.min.js"></script>
    </head>

    <body>
        <header class="header d-flex align-items-center justify-content-between fixed-top px-5">
            <a class="d-flex align-items-center text-decoration-none" href="/">
                <img class="logo" src="./assets/images/logo.png" alt="Logo Image">
                <div class="text-white">ADDRESS BOOK</div>
            </a>
            <nav class="d-flex align-items-center gap-4">
                <a class="text-white text-decoration-none" href="/">
                    <i class="fa-solid fa-user"></i>
                    Sign Up
                </a>
                <a class="text-white text-decoration-none" href="index.cfm">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    Login
                </a>
            </nav>
        </header>

        <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
            <div id="submitMsgSection" class="p-2"></div>
            <div class="row shadow-lg border-0 rounded-4 w-75">
                    <div class="col-md-4 d-flex align-items-center justify-content-center rounded-start-4">
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
                            Already have an account? <a class="text-decoration-none" href="index.cfm">Login</a>
                        </div>
                    </div>
            </div>
        </div>
		<script src="./js/bootstrap.bundle.min.js"></script>
        <script src="./js/signup.js"></script>
    </body>
</html>
