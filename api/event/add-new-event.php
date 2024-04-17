<?php

require_once('../error-handler.php');
require_once('../dbconfig.php');

require_once('../catalog-helper.php');
require_once('../date-time-helper.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}
$postData = file_get_contents('php://input');
$decodedEvent = json_decode($postData, true);
if (empty($decodedEvent)) {
    $conn->close();
    sendError('Empty Data.');
}
//-------- проверка юзера
$added_by = isset($decodedEvent["addedBy"]) ? intval($decodedEvent["addedBy"]) : 0;
if ($added_by <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($decodedEvent["sessionKey"]) ? $decodedEvent["sessionKey"] : '';
if (empty($session_key)) {
    $conn->close();
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

$sql = "SELECT session_key, status FROM User WHERE id = ?";
$params = [$added_by];
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

$address = isset($decodedEvent["address"]) ? $decodedEvent["address"] : null;
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

$is_active = isset($decodedEvent["isActive"]) ? boolval($decodedEvent["isActive"]) : false;
$is_checked = isset($decodedEvent["isChecked"]) ? boolval($decodedEvent["isChecked"]) : false;
$admin_notes = isset($decodedEvent["adminNotes"]) ? $decodedEvent["adminNotes"] : null;

//----- location
$isoCountryCode = $decodedEvent["isoCountryCode"];
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code is required.');
}

$country_name_en = isset($decodedEvent["countryNameEn"]) ? $decodedEvent["countryNameEn"] : null;
$region_name_en = isset($decodedEvent["regionNameEn"]) ? $decodedEvent["regionNameEn"] : null;
$city_name_en = isset($decodedEvent["cityNameEn"]) ? $decodedEvent["cityNameEn"] : null;

$country_id = $decodedEvent["countryId"];
$region_id = $decodedEvent["regionId"];
$city_id = $decodedEvent["cityId"];

$country_id = isset($country_id) ? intval($country_id) : getOrCreateCountryId($conn, $isoCountryCode, $country_name_en);
$region_id = isset($region_id) ? intval($region_id) : getOrCreateRegionId($conn, $country_id, $region_name_en);
$city_id = isset($city_id) ? intval($city_id) : getOrCreateCityId($conn, $country_id, $region_id, $city_name_en);
//-----

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

    $sql = "INSERT INTO Event (name, type_id, country_id, region_id, city_id, latitude, longitude, address, start_date, start_time, finish_date, finish_time, location, about, is_free, tickets, fee, email, phone, www, facebook, instagram, tags, owner_id, place_id, added_by, admin_notes, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $params = [$name, $type_id, $country_id, $region_id, $city_id, $latitude, $longitude, $address, $start_date, $start_time, $finish_date, $finish_time, $location, $about, $is_free, $tickets, $fee, $email, $phone, $www, $facebook, $instagram, $tags, $owner_id, $place_id, $added_by, $admin_notes, $is_active, $is_checked];
    $types = "siiiiddsssssssissssssssiiisii";

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
