<?php

require_once('../error-handler.php');
require_once('../dbconfig.php');

require_once('../catalog-helper.php');
require_once('../date-time-helper.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');

$decodedEvent = json_decode($postData, true);
if (empty($decodedEvent)) {
    sendError('Empty Data.');
}

//-------- проверка юзера
$user_id = isset($decodedEvent["addedBy"]) ? intval($decodedEvent["addedBy"]) : 0;
if ($user_id <= 0) {
    sendError('Invalid user ID.');
}
$session_key = isset($decodedEvent["sessionKey"]) ? $decodedEvent["sessionKey"] : '';
if (empty($decodedEvent)) {
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

$sql = "SELECT session_key, status FROM User WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('User not found.');
}
$row = $result->fetch_assoc();
$status = isset($row['status']) ? $row['status'] : '';
if (!($status === "admin" || $status === "moderator" || $status === "partner")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
//------------

$name = $decodedEvent["name"];
if (!isset($name)) {
    $conn->close();
    sendError('Event name is required.');
}
$type_id = isset($decodedEvent["type"]) ? intval($decodedEvent["type"]) : 0;

$longitude = isset($decodedEvent["longitude"]) ? floatval($decodedEvent["longitude"]) : null;
if ($longitude === null) {
    $conn->close();
    sendError('longitude is required.');
}
$latitude = isset($decodedEvent["latitude"]) ? floatval($decodedEvent["latitude"]) : null;
if ($latitude === null) {
    $conn->close();
    sendError('latitude is required.');
}
$address = $decodedEvent["address"];
if (!isset($address)) {
    $conn->close();
    sendError('ISO country code is required.');
}

$location = isset($decodedEvent["location"]) ? $decodedEvent["location"] : null;
$about = isset($decodedEvent["about"]) ? $decodedEvent["about"] : null;
$tickets = isset($decodedEvent["tickets"]) ? $decodedEvent["tickets"] : null;
$fee = isset($decodedEvent["fee"]) ? $decodedEvent["fee"] : null;
$is_free = isset($decodedEvent["isFree"]) ? boolval($decodedEvent["isFree"]) : false;
$email = isset($decodedEvent["email"]) ? $decodedEvent["email"] : null;
$phone = isset($decodedEvent["phone"]) ? $decodedEvent["phone"] : null;
$www = isset($decodedEvent["www"]) ? $decodedEvent["www"] : null;
$facebook = isset($decodedEvent["facebook"]) ? $decodedEvent["facebook"] : null;
$instagram = isset($decodedEvent["instagram"]) ? $decodedEvent["instagram"] : null;
$tags = isset($decodedEvent["tags"]) ? json_encode($decodedEvent["tags"]) : null;

$owner_id = isset($decodedEvent["ownerId"]) ? intval($decodedEvent["ownerId"]) : null;
$place_id = isset($decodedEvent["placeId"]) ? intval($decodedEvent["placeId"]) : null;

//todo только для модератора или админа
$is_active = isset($decodedEvent["isActive"]) ? boolval($decodedEvent["isActive"]) : false;
$is_checked = isset($decodedEvent["isChecked"]) ? boolval($decodedEvent["isChecked"]) : false;
//


//todo если есть country_id зачем $isoCountryCode ?
$country_id = $decodedEvent["countryId"];
$region_id = $decodedEvent["regionId"];
$city_id = $decodedEvent["cityId"];
$isoCountryCode = $decodedEvent["isoCountryCode"];
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code is required.');
}
//

$country_name = isset($decodedEvent["countryOrigin"]) ? $decodedEvent["countryOrigin"] : null;
$country_name_eng = isset($decodedEvent["countryEnglish"]) ? $decodedEvent["countryEnglish"] : null;

$region_name = isset($decodedEvent["regionOrigin"]) ? $decodedEvent["regionOrigin"] : null;
$region_name_eng = isset($decodedEvent["regionEnglish"]) ? $decodedEvent["regionEnglish"] : null;

$city_name = isset($decodedEvent["cityOrigin"]) ? $decodedEvent["cityOrigin"] : null;
$city_name_eng = isset($decodedEvent["cityEnglish"]) ? $decodedEvent["cityEnglish"] : null;

$country_id = isset($country_id) ? intval($country_id) : getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng);
$region_id = isset($region_id) ? intval($region_id) : getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng);
$city_id = isset($city_id) ? intval($city_id) : getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_eng);


if (!(isset($decodedEvent['repeatDates'])) && !(is_array($decodedEvent['repeatDates'])) && !(count($decodedEvent['repeatDates']) > 0)) {
    $conn->close();
    sendError('Date is required.');
}

$events_id = array();
foreach ($decodedEvent['repeatDates'] as $repeatDate) {

    if (!isset($repeatDate['startDate'])) {
        $conn->close();
        sendError('Start date is required.');
    }
    $start_date = convertToMySQLDate($repeatDate['startDate']);
    $start_time = isset($repeatDate["startTime"]) ? convertToMySQLTime($repeatDate["startTime"]) : null;
    $finish_date = isset($repeatDate["finishDate"]) ? convertToMySQLDate($repeatDate["finishDate"]) : null;
    $finish_time = isset($repeatDate["finishTime"]) ? convertToMySQLTime($repeatDate["finishTime"]) : null;

    $sql = "INSERT INTO Event (name, type_id, country_id, region_id, city_id, latitude, longitude, address, start_date, start_time, finish_date, finish_time, location, about, is_free, tickets, fee, email, phone, www, facebook, instagram, tags, owner_id, place_id, added_by, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $params = [$name, $type_id, $country_id, $region_id, $city_id, $latitude, $longitude, $address, $start_date, $start_time, $finish_date, $finish_time, $location, $about, $is_free, $tickets, $fee, $email, $phone, $www, $facebook, $instagram, $tags, $owner_id, $place_id, $user_id, $is_active, $is_checked];
    $types = "siiiiddsssssssissssssssiiiii";

    $stmt = executeQuery($conn, $sql, $params, $types);

    if (checkInsertResult($stmt, $conn, 'Failed to insert data into Event table.')) {
        $event_id = getLastInsertId($conn);
        array_push($events_id, $event_id);
    }
}

$conn->close();
$json = ['result' => true, 'ids' => $events_id];
echo json_encode($json, JSON_NUMERIC_CHECK);
exit;




////-<?php

require_once('../error-handler.php');
require_once('../dbconfig.php');

function getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng)
{
    if (!isset($isoCountryCode)) {
        sendError('ISO country code is required.');
    }
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
    if (!isset($region_name)) {
        sendError('region name_origin is required.');
    }

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
    if (!isset($city_name)) {
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

$name = $decodedEvent["name"];
if (!isset($name)) {
    sendError('name is required.');
}

$type_id = isset($decodedEvent["type"]) ? intval($decodedEvent["type"]) : 0;

$address = $decodedEvent["address"];
if (!isset($address)) {
    sendError('ISO country code is required.');
}
$longitude = isset($decodedEvent["longitude"]) ? floatval($decodedEvent["longitude"]) : null;
if ($longitude === null) {
    sendError('longitude is required.');
}
$latitude = isset($decodedEvent["latitude"]) ? floatval($decodedEvent["latitude"]) : null;
if ($latitude === null) {
    sendError('latitude is required.');
}
if (!isset($decodedEvent["startDate"])) {
    sendError('Start date is required.');
}
$start_date = convertToMySQLDate($decodedEvent["startDate"]);
$start_time = isset($decodedEvent["startTime"]) ? convertToMySQLTime($decodedEvent["startTime"]) : null;
$finish_date = isset($decodedEvent["finishDate"]) ? convertToMySQLDate($decodedEvent["finishDate"]) : null;
$finish_time = isset($decodedEvent["finishTime"]) ? convertToMySQLTime($decodedEvent["finishTime"]) : null;
$location = isset($decodedEvent["location"]) ? $decodedEvent["location"] : null;
$tickets = isset($decodedEvent["tickets"]) ? $decodedEvent["tickets"] : null;
$fee = isset($decodedEvent["fee"]) ? $decodedEvent["fee"] : null;
$is_free = isset($decodedEvent["isFree"]) ? boolval($decodedEvent["isFree"]) : false;
$email = isset($decodedEvent["email"]) ? $decodedEvent["email"] : null;
$phone = isset($decodedEvent["phone"]) ? $decodedEvent["phone"] : null;
$www = isset($decodedEvent["www"]) ? $decodedEvent["www"] : null;
$facebook = isset($decodedEvent["facebook"]) ? $decodedEvent["facebook"] : null;
$instagram = isset($decodedEvent["instagram"]) ? $decodedEvent["instagram"] : null;
$about = isset($decodedEvent["about"]) ? $decodedEvent["about"] : null;
$tags = isset($decodedEvent["tags"]) ? json_encode($decodedEvent["tags"]) : null;

$owner_id = isset($decodedEvent["ownerId"]) ? intval($decodedEvent["ownerId"]) : null;
$added_by = isset($decodedEvent["addedBy"]) ? intval($decodedEvent["addedBy"]) : null;
$added_by = isset($decodedEvent["addedBy"]) ? intval($decodedEvent["addedBy"]) : null;

$is_active = isset($decodedEvent["isActive"]) ? boolval($decodedEvent["isActive"]) : false;
$is_checked = isset($decodedEvent["isChecked"]) ? boolval($decodedEvent["isChecked"]) : false;


$country_id = $decodedEvent["countryId"];
$region_id = $decodedEvent["regionId"];
$city_id = $decodedEvent["cityId"];

$isoCountryCode = $decodedEvent["isoCountryCode"];
$country_name = isset($decodedEvent["countryOrigin"]) ? $decodedEvent["countryOrigin"] : null;
$country_name_eng = isset($decodedEvent["countryEnglish"]) ? $decodedEvent["countryEnglish"] : null;

$region_name = isset($decodedEvent["regionOrigin"]) ? $decodedEvent["regionOrigin"] : null;
$region_name_eng = isset($decodedEvent["regionEnglish"]) ? $decodedEvent["regionEnglish"] : null;

$city_name = isset($decodedEvent["cityOrigin"]) ? $decodedEvent["cityOrigin"] : null;
$city_name_eng = isset($decodedEvent["cityEnglish"]) ? $decodedEvent["cityEnglish"] : null;

$country_id = isset($country_id) ? intval($country_id) : getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng);
$region_id = isset($region_id) ? intval($region_id) : getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng);
$city_id = isset($city_id) ? intval($city_id) : getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_eng);

$place_id = isset($decodedEvent["placeId"]) ? intval($decodedEvent["placeId"]) : null;

$sql = "INSERT INTO Event (name, type_id, country_id, region_id, city_id, latitude, longitude, address, start_date, start_time, finish_date, finish_time, location, about, is_free, tickets, fee, email, phone, www, facebook, instagram, tags, owner_id, place_id, added_by, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

$params = [$name, $type_id, $country_id, $region_id, $city_id, $latitude, $longitude, $address, $start_date, $start_time, $finish_date, $finish_time, $location, $about, $is_free, $tickets, $fee, $email, $phone, $www, $facebook, $instagram, $tags, $owner_id, $place_id, $added_by, $is_active, $is_checked];
$types = "siiiiddsssssssissssssssiiiii";

$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Event table.')) {
    $event_id = getLastInsertId($conn);
    $conn->close();
    $json = ['result' => true, 'id' => $event_id];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
