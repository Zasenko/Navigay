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
$country_id = $data["id"];
if (!isset($country_id)) {
    sendError('Country ID is required.');
}
$country_id = intval($country_id);
if ($country_id <= 0) {
    sendError('Invalid country ID.');
}

$name_origin = isset($data["name_origin"]) ? $data["name_origin"] : null;
$name_en = isset($data["name_en"]) ? $data["name_en"] : null;
$flag_emoji = is_string($data["flag_emoji"]) ? $data["flag_emoji"] : null;
$about = isset($data["about"]) ? $data["about"] : null;
$show_regions = isset($data["show_regions"]) ? boolval($data["show_regions"]) : false;
$is_active = isset($data["is_active"]) ? boolval($data["is_active"]) : false;
$is_checked = isset($data["is_checked"]) ? boolval($data["is_checked"]) : false;

require_once('../dbconfig.php');

$sql = "UPDATE Country SET name_origin = ?, name_en = ?, flag_emoji = ?, about = ?, show_regions = ?, is_active = ?, is_checked = ? WHERE id = ?";
$params = [$name_origin, $name_en, $flag_emoji, $about, $show_regions, $is_active, $is_checked, $country_id];
$types = "ssssiiii";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update country table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
