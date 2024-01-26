<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);

if (empty($data)) {
    sendError('Empty Data.');
}
$city_id = $data["id"];
if (!isset($city_id)) {
    sendError('City ID is required.');
}
$city_id = intval($city_id);
if ($city_id <= 0) {
    sendError('Invalid city ID.');
}
$user_id = $data["user_id"];
if (empty($user_id)) {
    sendError('admin ID is required.');
}
$user_id = intval($user_id);
if ($user_id <= 0) {
    sendError('Invalid admin ID.');
}

$name_origin = isset($data["name_origin"]) ? $data["name_origin"] : null;
$name_en = isset($data["name_en"]) ? $data["name_en"] : null;

$about = isset($data["about"]) ? $data["about"] : null;
$is_active = isset($data["is_active"]) ? boolval($data["is_active"]) : false;
$is_checked = isset($data["is_checked"]) ? boolval($data["is_checked"]) : false;

require_once('../dbconfig.php');

$sql = "SELECT status FROM User WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if (!($result->num_rows > 0)) {
    $conn->close();
    sendUserError("User not found");
}

$row = $result->fetch_assoc();
$status = $row['status'];

if (!($status == "admin")) {
    $conn->close();
    sendUserError("User not admin");
}

$sql = "UPDATE City SET name_origin = ?, name_en = ?, about = ?, is_active = ?, is_checked = ? WHERE id = ?";
$params = [$name_origin, $name_en, $about, $is_active, $is_checked, $city_id];
$types = "sssiii";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update city.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
