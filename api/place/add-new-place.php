<?php

require_once('../error-handler.php');

function getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng)
{
    $sql = "SELECT id FROM Country WHERE isoCountryCode = ? LIMIT 1";
    $params = [$isoCountryCode];
    $types = "s";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $country_result = $stmt->get_result();
    $stmt->close();

    if ($country_result->num_rows > 0) {
        $row = $country_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO Country (isoCountryCode, name_origin, name_en) VALUES (?, ?, ?)";
        $params = [$isoCountryCode, $country_name, $country_name_eng];
        $types = "sss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (isoCountryCode: ' . $isoCountryCode . ', country name: ' . $country_name . ', country name eng :' . $country_name_eng . ') into Country table.')) {
            return getLastInsertId($conn);
        }
    }
}
function getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng)
{
    $sql = "SELECT id FROM Region WHERE country_id = ? AND name_origin = ? LIMIT 1";
    $params = [$country_id, $region_name];
    $types = "is";

    $sql = "SELECT id FROM Region WHERE country_id = ? AND (name_origin = ? OR (name_origin IS NULL AND ? IS NULL)) LIMIT 1";
    $params = [$country_id, $region_name, $region_name];
    $types = "iss";

    $stmt = executeQuery($conn, $sql, $params, $types);
    $region_result = $stmt->get_result();
    $stmt->close();

    if ($region_result->num_rows > 0) {
        $row = $region_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO Region (country_id, name_origin, name_en) VALUES (?, ?, ?)";
        $params = [$country_id, $region_name, $region_name_eng];
        $types = "iss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country_id: ' . $country_id . ', region name: ' . $region_name . ', region name eng :' . $region_name_eng . ') into Region table.')) {
            return getLastInsertId($conn);
        }
    }
}
function getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_eng)
{
    $sql = "SELECT id FROM City WHERE country_id = ? AND region_id = ? AND name_origin = ? LIMIT 1";
    $params = [$country_id, $region_id, $city_name];
    $types = "iis";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $city_result = $stmt->get_result();
    $stmt->close();

    if ($city_result->num_rows > 0) {
        $row = $city_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO City (country_id, region_id, name_origin, name_en) VALUES (?, ?, ?, ?)";
        $params = [$country_id, $region_id, $city_name, $city_name_eng];
        $types = "iiss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country id: ' . $country_id . ', region id: ' . $region_id . ', city name :' . $city_name . ', city name eng :' . $city_name_eng . ') into City table.')) {
            return getLastInsertId($conn);
        }
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedPlace = json_decode($postData, true);

if (empty($decodedPlace)) {
    sendError('Empty Data.');
}

$name = $decodedPlace["name"];
if (!isset($name)) {
    sendError('name is required.');
}
$type_id = isset($decodedPlace["type"]) ? intval($decodedPlace["type"]) : 0;

$isoCountryCode = $decodedPlace["isoCountryCode"];
if (!isset($isoCountryCode)) {
    sendError('ISO country code is required.');
}

$country_name = isset($decodedPlace["countryOrigin"]) ? $decodedPlace["countryOrigin"] : null;
$country_name_en = isset($decodedPlace["countryEnglish"]) ? $decodedPlace["countryEnglish"] : null;
$region_name = isset($decodedPlace["regionOrigin"]) ? $decodedPlace["regionOrigin"] : null;
$region_name_eng = isset($decodedPlace["regionEnglish"]) ? $decodedPlace["regionEnglish"] : null;
$city_name = isset($decodedPlace["cityOrigin"]) ? $decodedPlace["cityOrigin"] : null;
$city_name_en = isset($decodedPlace["cityEnglish"]) ? $decodedPlace["cityEnglish"] : null;

$address = $decodedPlace["address"];
if (!isset($address)) {
    sendError('ISO country code is required.');
}

$longitude = isset($decodedPlace["longitude"]) ? floatval($decodedPlace["longitude"]) : null;
if ($longitude == null) {
    sendError('longitude is required.');
}

$latitude = isset($decodedPlace["latitude"]) ? floatval($decodedPlace["latitude"]) : null;
if ($latitude == null) {
    sendError('latitude is required.');
}

$email = isset($decodedPlace["email"]) ? $decodedPlace["email"] : null;
$phone = isset($decodedPlace["phone"]) ? $decodedPlace["phone"] : null;
$www = isset($decodedPlace["www"]) ? $decodedPlace["www"] : null;
$facebook = isset($decodedPlace["facebook"]) ? $decodedPlace["facebook"] : null;
$instagram = isset($decodedPlace["instagram"]) ? $decodedPlace["instagram"] : null;
$about = isset($decodedPlace["about"]) ? $decodedPlace["about"] : null;
$tags = isset($decodedPlace["tags"]) ? json_encode($decodedPlace["tags"]) : null;
$timetable = isset($decodedPlace["timetable"]) ? json_encode($decodedPlace["timetable"]) : null;
$other_info = isset($decodedPlace["otherInfo"]) ? $decodedPlace["otherInfo"] : null;
$owner_id = isset($decodedPlace["ownerId"]) ? intval($decodedPlace["ownerId"]) : null;
$is_active = isset($decodedPlace["isActive"]) ? boolval($decodedPlace["isActive"]) : false;
$is_checked = isset($decodedPlace["isChecked"]) ? boolval($decodedPlace["isChecked"]) : false;

require_once('../dbconfig.php');

$country_id = getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_en);
$region_id = getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng);
$city_id = getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_en);

$sql = "INSERT INTO Place (name, type_id, country_id, region_id, city_id, address, latitude, longitude, email, phone, www, facebook, instagram, about, tags, timetable, other_info, owner_id, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
$params = [$name, $type_id, $country_id, $region_id, $city_id, $address, $latitude, $longitude, $email, $phone, $www, $facebook, $instagram, $about, $tags, $timetable, $other_info, $owner_id, $is_active, $is_checked];
$types = "siiiisddsssssssssiii";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Place table.')) {
    $place_id = getLastInsertId($conn);
    $conn->close();
    $json = ['result' => true, 'placeId' => $place_id];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
