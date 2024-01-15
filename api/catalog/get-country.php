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

$sql = "SELECT id, isoCountryCode, name_$language, about, flag_emoji, photo, show_regions, is_active, updated_at FROM Country WHERE id = ?";

$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$country_result = $stmt->get_result();
$stmt->close();
$row = $country_result->fetch_assoc();

//about
$about_data = json_decode($row['about'], true);
$selected_language_data = null;
$eng_language_data = null;
$any_language_data = null;
if (is_array($about_data)) {
    foreach ($about_data as $aboutItem) {
        if ($aboutItem['language'] === $language) {
            $selected_language_data = $aboutItem['about'];
            break;
        } else if ($aboutItem['language'] === 'en') {
            $eng_language_data = $aboutItem['about'];
            break;
        }
        $any_language_data = $aboutItem['about'];
    }
}
$about = $selected_language_data ?? $eng_language_data ?? $any_language_data;
//show_regions
$show_regions = (bool)$row['show_regions'];
//is_active
$is_active = (bool)$row['is_active'];
//photo
$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

$country = array(
    'id' => $row['id'],
    'isoCountryCode' => $row['isoCountryCode'],
    'name' => $row["name_$language"],
    'flag_emoji' => $row['flag_emoji'],
    'photo' => $photo_url,
    'about' => $about,
    'show_regions' => $show_regions,
    'is_active' => $is_active,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name_$language, photo, is_active, updated_at FROM Region WHERE country_id = ? AND is_active = true";
$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$regions_result = $stmt->get_result();
$stmt->close();

$regions = array();
while ($row = $regions_result->fetch_assoc()) {

    //is_active
    $is_active = (bool)$row['is_active'];
    //photo
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    //id
    $region_id = $row['id'];

    $region = array(
        'id' => $region_id,
        'name' => $row["name_$language"],
        'photo' => $photo_url,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at']
    );

    $sql = "SELECT id, name_$language, photo, is_active, updated_at FROM City WHERE region_id = ? AND is_active = true";
    $params = [$region_id];
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    $cities = array();
    while ($row = $cities_result->fetch_assoc()) {

        //is_active
        $is_active = (bool)$row['is_active'];
        //photo
        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $city = array(
            'id' => $row['id'],
            'name' => $row["name_$language"],
            'photo' => $photo_url,
            'is_active' => $is_active,
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
