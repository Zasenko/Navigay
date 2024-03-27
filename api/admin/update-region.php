<?php

require_once('../error-handler.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}
$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    sendError('Empty Data.');
}

$region_id = isset($data["region_id"]) ? intval($data["region_id"]) : 0;
if ($region_id <= 0) {
    $conn->close();
    sendError('Invalid region ID.');
}

$name_en = isset($data["name_en"]) ? $data["name_en"] : null;
$is_active = isset($data["is_active"]) ? boolval($data["is_active"]) : false;
$is_checked = isset($data["is_checked"]) ? boolval($data["is_checked"]) : false;

//-------- проверка юзера
$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
if ($user_id <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($data["session_key"]) ? $data["session_key"] : '';
if (empty($session_key)) {
    $conn->close();
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

$sql = "SELECT session_key, status FROM User WHERE id = ?";
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

$user_status = isset($row['status']) ? $row['status'] : '';
if (!($user_status === "admin" || $user_status === "moderator")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
//-----------------

$sql = "UPDATE Region SET name_en = ?, is_active = ?, is_checked = ? WHERE id = ?";
$params = [$name_en, $is_active, $is_checked, $region_id];
$types = "siii";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update region table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
