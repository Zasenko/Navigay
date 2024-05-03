<?php

//можно удалять из базы евенты сроком окончиния - год
//можно удалять из базы неактивные места сроком окончиния - 3 года

require_once('../error-handler.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}
$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    $conn->close();
    sendError('Invalid or empty request data.');
}

//-------- проверка юзера
$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
if ($user_id <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($data["session_key"]) ? $data["session_key"] : '';
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
if (!($user_status === "admin" || $user_status === "moderator")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
//-----------------

$sql = "SELECT id, isoCountryCode, name_en, is_active, is_checked FROM Country WHERE is_checked = false";
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
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name_en' => $row['name_en'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($countries, $country);
}

$sql = "SELECT id, country_id, name_en, is_active, is_checked FROM Region WHERE is_checked = false";
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
$regions = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $region = array(
        'id' => $row['id'],
        'country_id' => $row['country_id'],
        'name_en' => $row['name_en'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($regions, $region);
}


//-----
$sql = "SELECT id, country_id, region_id, name_en, is_active, is_checked FROM City WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for City.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for City.');
}
$result = $stmt->get_result();
$stmt->close();
$cities = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];

    // $photo = $row['photo'];
    // $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    // $photos = json_decode($row['photos'], true);
    // $library_photos = array();

    // if (is_array($photos)) {
    //     foreach ($photos as $photoData) {
    //         if (isset($photoData['url']) && && isset($photoData['id'])) {
    //             $library_photo = array(
    //                 'id' => strval($photoData['id']),
    //                 'url' => "https://www.navigay.me/" . $photoData['url']
    //             );
    //             array_push($library_photos, $library_photo);
    //         }
    //     }
    // }
    $city = array(
        'id' => $row['id'],
        'country_id' => $row["country_id"],
        'region_id' => $row['region_id'],
        //  'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        // 'about' => $about_data,
        // 'photo' => $photo_url,
        // 'photos' => $library_photos,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($cities, $city);
}

//----------------------------

$sql = "SELECT id, name, type_id FROM Place WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Place.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Plcae.');
}
$result = $stmt->get_result();
$stmt->close();
$places = array();
while ($row = $result->fetch_assoc()) {
    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
    );
    array_push($places, $place);
}
//--------


//----------------------------

$sql = "SELECT id, name, type_id FROM Event WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Place.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Plcae.');
}
$result = $stmt->get_result();
$stmt->close();
$events = array();
while ($row = $result->fetch_assoc()) {
    $event = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
    );
    array_push($events, $event);
}
//--------

$conn->close();
$info = ['countries' => $countries, 'regions' => $regions, 'cities' => $cities, 'places' => $places, 'events' => $events];
$json = ['result' => true, 'info' => $info];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
