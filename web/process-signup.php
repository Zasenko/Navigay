<?php

if(empty($_POST["name"])){
    die("Name is required");
}
if ( ! filter_var($_POST["email"], FILTER_VALIDATE_EMAIL)) {
    die("Valid email");
}

if (strlen($_POST["password"]) < 8) {
    die("Password must be at least 8 characters");
}

if ( ! preg_match("/[a-z]/i", $_POST["password"])) {
    die("Password must contain at least one letter");
}
if ( ! preg_match("/[0-9]/", $_POST["password"])) {
    die("Password must contain at least one nummber");
}

if ($_POST["password"] !== $_POST["password_confirmation"]) {
    die("Password must match");
}

$password_hash = password_hash($_POST["password"], PASSWORD_DEFAULT);

$con = require __DIR__ . "/database.php";

$sql = "INSERT INTO User (email, password, name, pic, bio) VALUES (?, ?, ?, ?, ?)";


$stmt = $con->stmt_init();

if ( ! $stmt->prepare($sql)) {
    die("SQL error: " . $con->error);
}

$stmt->bind_param("sssss", $_POST["email"], $_POST["password"], $_POST["name"], $_POST["pic"], $_POST["bio"]);
if ($stmt->execute()) {
    echo "Signup successful";
} else {
    die($con->error . " " . $con->errno);
}


?>