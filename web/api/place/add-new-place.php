<?php

require_once('../error-handler.php');
require_once('../catalog-helper.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedPlace = json_decode($postData, true);

if (empty($decodedPlace)) {
    $conn->close();
    sendError('Empty Data.');
}

//-------- проверка юзера
$user_id = isset($decodedPlace["addedBy"]) ? intval($decodedPlace["addedBy"]) : 0;
if ($user_id <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($decodedPlace["sessionKey"]) ? $decodedPlace["sessionKey"] : '';
if (empty($session_key)) {
    $conn->close();
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
$user_status = isset($row['status']) ? $row['status'] : '';
if (!($user_status === "admin" || $user_status === "moderator" || $user_status === "partner")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}

//------------


$name = $decodedPlace["name"];
if (!isset($name)) {
    $conn->close();
    sendError('name is required.');
}
$type_id = isset($decodedPlace["type"]) ? intval($decodedPlace["type"]) : 0;

$address = $decodedPlace["address"];
if (!isset($address)) {
    $conn->close();
    sendError('address is required.');
}
$longitude = isset($decodedPlace["longitude"]) ? floatval($decodedPlace["longitude"]) : null;
if ($longitude == null) {
    $conn->close();
    sendError('longitude is required.');
}
$latitude = isset($decodedPlace["latitude"]) ? floatval($decodedPlace["latitude"]) : null;
if ($latitude == null) {
    $conn->close();
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
$admin_notes = isset($decodedPlace["adminNotes"]) ? $decodedPlace["adminNotes"] : null;
$is_active = isset($decodedPlace["isActive"]) ? boolval($decodedPlace["isActive"]) : false;
$is_checked = isset($decodedPlace["isChecked"]) ? boolval($decodedPlace["isChecked"]) : false;


//----- location
$isoCountryCode = $decodedPlace["isoCountryCode"];
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code is required.');
}

$country_name_en = isset($decodedPlace["countryNameEn"]) ? $decodedPlace["countryNameEn"] : null;
$region_name_en = isset($decodedPlace["regionNameEn"]) ? $decodedPlace["regionNameEn"] : null;
$city_name_en = isset($decodedPlace["cityNameEn"]) ? $decodedPlace["cityNameEn"] : null;

$country_id = $decodedPlace["countryId"];
$region_id = $decodedPlace["regionId"];
$city_id = $decodedPlace["cityId"];

$country_id = isset($country_id) ? intval($country_id) : getOrCreateCountryId($conn, $isoCountryCode, $country_name_en);
$region_id = isset($region_id) ? intval($region_id) : getOrCreateRegionId($conn, $country_id, $region_name_en);
$city_id = isset($city_id) ? intval($city_id) : getOrCreateCityId($conn, $country_id, $region_id, $city_name_en);
//-----

$sql = "INSERT INTO Place (name, type_id, country_id, region_id, city_id, address, latitude, longitude, email, phone, www, facebook, instagram, about, tags, timetable, other_info, owner_id, admin_notes, is_active, is_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
$params = [$name, $type_id, $country_id, $region_id, $city_id, $address, $latitude, $longitude, $email, $phone, $www, $facebook, $instagram, $about, $tags, $timetable, $other_info, $owner_id, $admin_notes, $is_active, $is_checked];
$types = "siiiisddsssssssssisii";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Place table.')) {
    $place_id = getLastInsertId($conn);
    $conn->close();
    $json = ['result' => true, 'placeId' => $place_id];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
