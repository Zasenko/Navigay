<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$sql = "SELECT id, isoCountryCode, name_en, flag_emoji, photo, show_regions, updated_at FROM Country WHERE is_active = true";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    $conn->close();
    sendError('Failed to prepare SQL statement: ' . $error);
}
if (!$stmt->execute()) {
    $error = $stmt->error;
    $stmt->close();
    $conn->close();
    sendError('Execute error: ' . $error);
}
$result = $stmt->get_result();
$stmt->close();

$countries = array();
while ($row = $result->fetch_assoc()) {

    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];

    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name' => $row["name_en"],
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $photo_url,
        'show_regions' => $show_regions,
        'updated_at' => $row['updated_at'],
    );
    array_push($countries, $country);
}
$conn->close();
$json = array('result' => true, 'countries' => $countries);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
