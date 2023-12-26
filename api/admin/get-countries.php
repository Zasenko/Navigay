<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

//TODO! проверка юзера на то, что он администратор

require_once('../dbconfig.php');

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
        'show_regions' => $show_regions,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($countries, $country);
}
$conn->close();
$json = ['result' => true, 'countries' => $countries];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
