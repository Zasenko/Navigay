<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

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

//TODO! проверка юзера на то, что он администратор

require_once('../dbconfig.php');

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

$status = $row['status'];
if (!($status === "admin")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
$hashed_session_key = hash('sha256', $session_key);
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong key.');
}

$sql = "SELECT id, isoCountryCode, name_origin, name_en, show_regions, is_active, is_checked FROM Country";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Country.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Country.');
}
$result = $stmt->get_result();
$stmt->close();
$countries = array();
while ($row = $result->fetch_assoc()) {
    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row["isoCountryCode"],
        'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($countries, $country);
}
$conn->close();
$json = ['result' => true, 'countries' => $countries];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
