<?php

require_once('../error-handler.php');
require_once('../languages.php');
require_once('auth-user-error.php');

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

require_once("../dbconfig.php");

$sql = "SELECT * FROM User WHERE email = ? LIMIT 1";
$params = [$user_email];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if (!($result->num_rows > 0)) {
    $conn->close();
    $errorDescription = getAuthErrorMessage(5, $user_language);
    sendUserError($errorDescription);
}

$row = $result->fetch_assoc();
$user_id = $row['id'];

if (!password_verify($user_password, $row['password'])) {
    $conn->close();
    $errorDescription = getAuthErrorMessage(7, $user_language);
    sendUserError($errorDescription);
}

$session_key = bin2hex(random_bytes(16));
$hashed_session_key = hash('sha256', $session_key);

// $sql = "UPDATE User SET last_time_online = CURRENT_TIMESTAMP() WHERE id = ?";
$sql = "UPDATE User SET session_key = ? WHERE id = ?";
$params = [$hashed_session_key, $user_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to update user with ID ' . $user_id)) {
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    $user = array(
        'id' => $user_id,
        'name' => $row['name'],
        'email' => $row['email'],
        'status' => $row['status'],
        'bio' => $row["bio"],
        'photo' => $photo_url,
        'updated_at' => $row['updated_at'],
        'session_key' => $session_key,
    );

    $conn->close();
    $json = array('result' => true, 'user' => $user);
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}
