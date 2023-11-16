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
$region_id = $data["id"];
if (!isset($region_id)) {
    sendError('Region ID is required.');
}
$region_id = intval($region_id);
if ($region_id <= 0) {
    sendError('Invalid region ID.');
}

$name_origin = isset($data["name_origin"]) ? htmlspecialchars($data["name_origin"]) : null;
$name_en = isset($data["name_en"]) ? htmlspecialchars($data["name_en"]) : null;
$name_fr = isset($data["name_fr"]) ? htmlspecialchars($data["name_fr"]) : null;
$name_de = isset($data["name_de"]) ? htmlspecialchars($data["name_de"]) : null;
$name_ru = isset($data["name_ru"]) ? htmlspecialchars($data["name_ru"]) : null;
$name_it = isset($data["name_it"]) ? htmlspecialchars($data["name_it"]) : null;
$name_es = isset($data["name_es"]) ? htmlspecialchars($data["name_es"]) : null;
$name_pt = isset($data["name_pt"]) ? htmlspecialchars($data["name_pt"]) : null;
$is_active = isset($data["is_active"]) ? boolval($data["is_active"]) : false;
$is_checked = isset($data["is_checked"]) ? boolval($data["is_checked"]) : false;

require_once('../dbconfig.php');

$sql = "UPDATE Region SET name_origin = ?, name_en = ?, name_fr = ?, name_de = ?, name_ru = ?, name_it = ?, name_es = ?, name_pt = ?, is_active = ?, is_checked = ? WHERE id = ?";
$params = [$name_origin, $name_en, $name_fr, $name_de, $name_ru, $name_it, $name_es, $name_pt, $is_active, $is_checked, $region_id];
$types = "ssssssssiii";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update region table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
