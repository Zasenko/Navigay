<?php

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

$place_id = isset($data["place_id"]) ? intval($data["place_id"]) : 0;
if ($place_id <= 0) {
    $conn->close();
    sendError('Invalid place ID.');
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
if (!($user_status === "admin" || $user_status === "moderator" || $user_status === "partner")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
//-----------------

$sql = "SELECT * FROM Place WHERE id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if ($result->num_rows === 0) {
    $conn->close();
    sendError('Place with id ' . $place_id . ' not found.');
}
$row = $result->fetch_assoc();

$owner_id = $row['owner_id'];

//------- проверка доступа к месту
if ($user_status === "partner") {
    if (!($user_id === intval($owner_id))) {
        $conn->close();
        sendError('Not enough access rights.');
    }
}
//-----------------------------

$is_active = (bool)$row['is_active'];
$is_checked = (bool)$row['is_checked'];

$avatar = $row['avatar'];
$avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
$main_photo = $row['main_photo'];
$main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;
$photos = json_decode($row['photos'], true);
$library_photos = array();

if (is_array($photos)) {
    foreach ($photos as $photoData) {
        if (isset($photoData['url']) && isset($photoData['id'])) {
            $library_photo = array(
                'id' => strval($photoData['id']),
                'url' => "https://www.navigay.me/" . $photoData['url']
            );
            array_push($library_photos, $library_photo);
        }
    }
}
//todo на проверку
$tags_data = json_decode($row['tags'], true);
$timetable = json_decode($row['timetable'], true);

//--------
$place = array(
    'id' => $row['id'],
    'name' => $row["name"],
    'type_id' => $row['type_id'],
    'country_id' => $row['country_id'],
    'region_id' => $row['region_id'],
    'city_id' => $row['city_id'],
    'about' => $row['about'],
    'avatar' => $avatar_url,
    'main_photo' => $main_photo_url,
    'photos' => $library_photos,
    'address' => $row['address'],
    'longitude' => $row['longitude'],
    'latitude' => $row['latitude'],
    'email' => $row['email'],
    'phone' => $row['phone'],
    'www' => $row['www'],
    'facebook' => $row['facebook'],
    'instagram' => $row['instagram'],
    'tags' => $tags_data,
    'timetable' => $timetable,
    'other_info' => $row['other_info'],
    'owner_id' => $row['owner_id'],
    'added_by' => $row['added_by'],
    'is_active' => $is_active,
    'is_checked' => $is_checked,
    'created_at' => $row['created_at'],
    'updated_at' => $row['updated_at'],
);
$conn->close();
$json = ['result' => true, 'place' => $place];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
