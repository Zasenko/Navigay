<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    sendError('Invalid or empty request data.');
}

$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
if ($user_id <= 0) {
    sendError('Invalid user ID.');
}

$session_key = isset($data["session_key"]) ? $data["session_key"] : '';
if (empty($session_key)) {
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

require_once("../dbconfig.php");

$sql = "SELECT session_key FROM User WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('User not found.');
}

$row = $result->fetch_assoc();
$stored_hashed_session_key = $row['session_key'];

if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}

$sql = "UPDATE User SET session_key = null WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to update user with ID ' . $user_id)) {
    $conn->close();
    $json = array('result' => true);
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}
