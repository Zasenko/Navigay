<?php

require_once('auth-user-error.php');
require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);

if (empty($data)) {
    sendError('Invalid or empty request data.');
}

$user_language = isset($data["language"]) && in_array($data["language"], $languages) ? $data["language"] : 'en';

$user_email = isset($data["email"]) ? filter_var($data["email"], FILTER_SANITIZE_EMAIL) : "";
$user_email = filter_var($user_email, FILTER_VALIDATE_EMAIL);
if (!$user_email) {
    $errorDescription = getAuthErrorMessage(1, $user_language);
    sendUserError($errorDescription);
}

$user_password = isset($data["password"]) ? $data["password"] : "";
if (strlen($user_password) < 8) {
    $errorDescription = getAuthErrorMessage(2, $user_language);
    sendUserError($errorDescription);
}
if (!preg_match("/[a-zA-Z]/", $user_password)) {
    $errorDescription = getAuthErrorMessage(3, $user_language);
    sendUserError($errorDescription);
}
if (!preg_match("/[0-9]/", $user_password)) {
    $errorDescription = getAuthErrorMessage(4, $user_language);
    sendUserError($errorDescription);
}

$user_email_name = strstr($user_email, '@', true);
$user_name = is_numeric($user_email_name) ? 'user_' . $user_email_name : $user_email_name;

$hashed_password = password_hash($user_password, PASSWORD_DEFAULT);

require_once("../dbconfig.php");

$sql = "SELECT * FROM User WHERE email = ? LIMIT 1";
$params = [$user_email];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows > 0) {
    $conn->close();
    $errorDescription = getAuthErrorMessage(6, $user_language);
    sendUserError($errorDescription);
}

$sql = "INSERT INTO User (email, password, name) VALUES (?, ?, ?)";
$params = [$user_email, $hashed_password, $user_name];
$types = "sss";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into User table.')) {
    $user_id = getLastInsertId($conn);
    $conn->close();
    $user = array(
        'id' => $user_id,
        'name' => $user_name,
        'email' => $user_email,
        'status' => "user",
    );
    $json = array('result' => true, 'user' => $user);
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
