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
    $conn->close();
    sendError('Invalid or empty request data.');
}

$region_id = isset($data["region_id"]) ? intval($data["region_id"]) : 0;
if ($region_id <= 0) {
    $conn->close();
    sendError('Invalid region ID.');
}
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

$sql = "SELECT * FROM Region WHERE id = ?";
$params = [$region_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('User not found.');
}
$row = $result->fetch_assoc();
$is_checked = (bool)$row['is_checked'];
$is_active = (bool)$row['is_active'];

$photo_url = isset($row['photo']) ? "https://www.navigay.me/" . $row['photo'] : null;
$region = array(
    'id' => $row['id'],
    'country_id' => $row["country_id"],
    'name_origin_en' => $row['name_origin_en'],
    'name_en' => $row['name_en'],
    'photo' => $photo_url,
    'redirect_region_id' => $row['redirect_region_id'],
    'is_active' => $is_active,
    'is_checked' => $is_checked,
);

$conn->close();
$json = ['result' => true, 'region' => $region];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
