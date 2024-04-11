<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$country_id = (int)$_GET["id"];

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$sql = "SELECT id, isoCountryCode, name_en, about, flag_emoji, photo, show_regions, updated_at FROM Country WHERE id = ?";

$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$country_result = $stmt->get_result();
$stmt->close();

if ($country_result->num_rows === 0) {
    $conn->close();
    sendError('Country not found.');
}
$row = $country_result->fetch_assoc();

$show_regions = (bool)$row['show_regions'];

$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

$country = array(
    'id' => $row['id'],
    'isoCountryCode' => $row['isoCountryCode'],
    'name' => $row["name_en"],
    'flag_emoji' => $row['flag_emoji'],
    'photo' => $photo_url,
    'about' => $row['about'],
    'show_regions' => $show_regions,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name_en, small_photo, photo, updated_at FROM Region WHERE country_id = ? AND is_active = true";
$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$regions_result = $stmt->get_result();
$stmt->close();

$regions = array();
while ($row = $regions_result->fetch_assoc()) {

    $region_id = $row['id'];
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $region = array(
        'id' => $region_id,
        'name' => $row["name_en"],
        'photo' => $photo_url,
        'updated_at' => $row['updated_at']
    );

    $sql = "SELECT id, name_en, photo, updated_at FROM City WHERE region_id = ? AND is_active = true";
    $params = [$region_id];
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    $cities = array();
    while ($row = $cities_result->fetch_assoc()) {

        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
        $small_photo = $row['small_photo'];
        $small_photo_url = isset($small_photo) ? "https://www.navigay.me/" . $small_photo : null;

        $city = array(
            'id' => $row['id'],
            'name' => $row["name_en"],
            'small_photo' => $small_photo_url,
            'photo' => $photo_url,
            'updated_at' => $row['updated_at']
        );
        array_push($cities, $city);
    }
    $region += ['cities' => $cities];

    if (count($cities) > 0) {
        array_push($regions, $region);
    }
}

$country += ['regions' => $regions];

$conn->close();
$json = array('result' => true, 'country' => $country);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
