<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedCountry = json_decode($postData, true);

if (empty($decodedCountry)) {
    sendError('Empty Data.');
}
$country_id = $decodedCountry["id"];
if (!isset($country_id)) {
    sendError('Country ID is required.');
}
$country_id = intval($country_id);
if ($country_id <= 0) {
    sendError('Invalid country ID.');
}

$name_origin = isset($decodedCountry["name"]) ? htmlspecialchars($decodedCountry["name"]) : null;
$name_en = isset($decodedCountry["name_en"]) ? htmlspecialchars($decodedCountry["name_en"]) : null;
$name_fr = isset($decodedCountry["name_fr"]) ? htmlspecialchars($decodedCountry["name_fr"]) : null;
$name_de = isset($decodedCountry["name_de"]) ? htmlspecialchars($decodedCountry["name_de"]) : null;
$name_ru = isset($decodedCountry["name_ru"]) ? htmlspecialchars($decodedCountry["name_ru"]) : null;
$name_it = isset($decodedCountry["name_it"]) ? htmlspecialchars($decodedCountry["name_it"]) : null;
$name_es = isset($decodedCountry["name_es"]) ? htmlspecialchars($decodedCountry["name_es"]) : null;
$name_pt = isset($decodedCountry["name_pt"]) ? htmlspecialchars($decodedCountry["name_pt"]) : null;
$flag_emoji = is_string($decodedCountry["flag_emoji"]) ? $decodedCountry["flag_emoji"] : null;
$about = isset($decodedCountry["about"]) ? json_encode($decodedCountry["about"]) : null;
$show_regions = isset($decodedCountry["show_regions"]) ? boolval($decodedCountry["show_regions"]) : false;
$is_active = isset($decodedCountry["is_active"]) ? boolval($decodedCountry["is_active"]) : false;
$is_checked = isset($decodedCountry["is_checked"]) ? boolval($decodedCountry["is_checked"]) : false;

require_once('../dbconfig.php');

$sql = "UPDATE Country SET name_origin = ?, name_en = ?, name_fr = ?, name_de = ?, name_ru = ?, name_it = ?, name_es = ?, name_pt = ?, flag_emoji = ?, about = ?, show_regions = ?, is_active = ?, is_checked = ? WHERE id = ?";
$params = [$name_origin, $name_en, $name_fr, $name_de, $name_ru, $name_it, $name_es, $name_pt, $flag_emoji, $about, $show_regions, $is_active, $is_checked, $country_id];
$types = "ssssssssssiiii";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update country table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
