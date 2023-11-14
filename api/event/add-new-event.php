<?php

require_once('../error-handler.php');

function getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_engg)
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
        $params = [$isoCountryCode, $country_name, $country_name_engg];
        $types = "sss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (isoCountryCode: ' . $isoCountryCode . ', country name: ' . $country_name . ', country name eng :' . $country_name_engg . ') into Country table.')) {
            return getLastInsertId($conn);
        }
    }
}
function getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng)
{
    $sql = "SELECT id FROM Region WHERE country_id = ? AND name_origin = ? LIMIT 1";
    $params = [$country_id, $region_name];
    $types = "is";
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
    if ($city_name === null || $city_name_eng === null) {
        return null;
    }

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

function convertToMySQLDate($dateString)
{
    try {
        $dateTime = new DateTime($dateString);
        return $dateTime->format('Y-m-d');
    } catch (Exception $e) {
        sendError('Error converting date: ' . $e->getMessage());
    }
}
function convertToMySQLTime($timeString)
{
    try {
        $dateTime = new DateTime($timeString);
        return $dateTime->format('H:i');
    } catch (Exception $e) {
        sendError('Error converting time: ' . $e->getMessage());
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedEvent = json_decode($postData, true);
if (empty($decodedEvent)) {
    sendError('Empty Data.');
}

$name = isset($decodedEvent["name"]) ? htmlspecialchars($decodedEvent["name"]) : "";
$type_id = isset($decodedEvent["type"]) ? intval($decodedEvent["type"]) : 0;
if (!isset($decodedEvent["isoCountryCode"])) {
    sendError('ISO country code is required.');
}
$isoCountryCode = htmlspecialchars($decodedEvent["isoCountryCode"]);
$country_name = isset($decodedEvent["countryOrigin"]) ? htmlspecialchars($decodedEvent["countryOrigin"]) : null;
$country_name_eng = isset($decodedEvent["countryEnglish"]) ? htmlspecialchars($decodedEvent["countryEnglish"]) : null;
$region_name = isset($decodedEvent["regionOrigin"]) ? htmlspecialchars($decodedEvent["regionOrigin"]) : null;
$region_name_eng = isset($decodedEvent["regionEnglish"]) ? htmlspecialchars($decodedEvent["regionEnglish"]) : null;
$city_name = isset($decodedEvent["cityOrigin"]) ? htmlspecialchars($decodedEvent["cityOrigin"]) : null;
$city_name_eng = isset($decodedEvent["cityEnglish"]) ? htmlspecialchars($decodedEvent["cityEnglish"]) : null;
$address = isset($decodedEvent["address"]) ? htmlspecialchars($decodedEvent["address"]) : "";
$longitude = isset($decodedEvent["longitude"]) ? floatval($decodedEvent["longitude"]) : 0.0;
$latitude = isset($decodedEvent["latitude"]) ? floatval($decodedEvent["latitude"]) : 0.0;

if (!isset($decodedEvent["startDate"])) {
    sendError('Start date is required.');
}
$start_date = convertToMySQLDate($decodedEvent["startDate"]);
$start_time = isset($decodedEvent["startTime"]) ? convertToMySQLTime($decodedEvent["startTime"]) : null;
$finish_date = isset($decodedEvent["finishDate"]) ? convertToMySQLDate($decodedEvent["finishDate"]) : null;
$finish_time = isset($decodedEvent["finishTime"]) ? convertToMySQLTime($decodedEvent["finishTime"]) : null;

$location = isset($decodedEvent["location"]) ? htmlspecialchars($decodedEvent["location"]) : null;
$tickets = isset($decodedEvent["tickets"]) ? htmlspecialchars($decodedEvent["tickets"]) : null;
$fee = isset($decodedEvent["fee"]) ? htmlspecialchars($decodedEvent["fee"]) : null;
$is_free = isset($decodedEvent["isFree"]) ? boolval($decodedEvent["isFree"]) : false;

$email = isset($decodedEvent["email"]) ? htmlspecialchars($decodedEvent["email"]) : null;
$phone = isset($decodedEvent["phone"]) ? htmlspecialchars($decodedEvent["phone"]) : null;
$www = isset($decodedEvent["www"]) ? htmlspecialchars($decodedEvent["www"]) : null;
$facebook = isset($decodedEvent["facebook"]) ? htmlspecialchars($decodedEvent["facebook"]) : null;
$instagram = isset($decodedEvent["instagram"]) ? htmlspecialchars($decodedEvent["instagram"]) : null;

$about = isset($decodedEvent["about"]) ? json_encode($decodedEvent["about"]) : null;
$tags = isset($decodedEvent["tags"]) ? json_encode($decodedEvent["tags"]) : null;

$owner_id = isset($decodedEvent["ownerId"]) ? intval($decodedEvent["ownerId"]) : null;

$added_by = isset($decodedEvent["addedBy"]) ? intval($decodedEvent["addedBy"]) : null;
$is_active = isset($decodedEvent["isActive"]) ? boolval($decodedEvent["isActive"]) : false;
$is_checked = isset($decodedEvent["isChecked"]) ? boolval($decodedEvent["isChecked"]) : false;

require_once('../dbconfig.php');

$country_id = getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng);
$region_id = getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng);
$city_id = getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_eng);

$sql = "INSERT INTO Event (name, type_id, country_id, region_id, city_id, latitude, longitude, address, start_date, start_time, finish_date, finish_time, location, about, is_free, tickets, fee, email, phone, www, facebook, instagram, tags, owner_id, place_id, added_by, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

$params = [$name, $type_id, $country_id, $region_id, $city_id, $latitude, $longitude, $address, $start_date, $start_time, $finish_date, $finish_time, $location, $about, $is_free, $tickets, $fee, $email, $phone, $www, $facebook, $instagram, $tags, $owner_id, $place_id, $added_by, $is_active, $is_checked];
$types = "siiiiddsssssssissssssssiiiii";

$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Event table.')) {
    $place_id = getLastInsertId($conn);
    $conn->close();
    $json = ['result' => true, 'placeId' => $place_id];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
