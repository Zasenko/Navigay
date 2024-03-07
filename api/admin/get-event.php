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

$event_id = isset($data["event_id"]) ? intval($data["event_id"]) : 0;
if ($event_id <= 0) {
    $conn->close();
    sendError('Invalid Event ID.');
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
//-----------------

$sql = "SELECT * FROM Event WHERE id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if ($result->num_rows === 0) {
    $conn->close();
    sendError('Event with id ' . $event_id . ' not found.');
}
$row = $result->fetch_assoc();

$owner_id = $row['owner_id'];

//------- проверка доступа к месту
if ($status === "partner") {
    if (!($user_id === intval($owner_id))) {
        $conn->close();
        sendError('Not enough access rights.');
    }
}
//-----------------------------

$is_active = (bool)$row['is_active'];
$is_checked = (bool)$row['is_checked'];
$is_free = (bool)$row['is_free'];

$poster_small = $row['poster_small'];
$poster_small_url = isset($poster_small) ? "https://www.navigay.me/" . $poster_small : null;

$poster = $row['poster'];
$poster_url = isset($poster) ? "https://www.navigay.me/" . $poster : null;

//todo на проверку
$tags_data = json_decode($row['tags'], true);
//-----------------


//--------
$event = array(
    'id' => $row['id'],
    'name' => $row["name"],
    'type_id' => $row['type_id'],
    'country_id' => $row['country_id'],
    'region_id' => $row['region_id'],
    'city_id' => $row['city_id'],
    'longitude' => $row['longitude'],
    'latitude' => $row['latitude'],
    'address' => $row['address'],
    'start_date' => $row['start_date'],
    'start_time' => $row['start_time'],
    'finish_date' => $row['finish_date'],
    'finish_time' => $row['finish_time'],
    'location' => $row['location'],
    'about' => $row['about'],
    'poster' => $poster_url,
    'poster_small' => $poster_small_url,
    'is_free' => $is_free,
    'tickets' => $row['tickets'],
    'fee' => $row['fee'],
    'email' => $row['email'],
    'phone' => $row['phone'],
    'www' => $row['www'],
    'facebook' => $row['facebook'],
    'instagram' => $row['instagram'],
    'tags' => $tags_data,
    'owner_id' => $row['owner_id'],
    'place_id' => $row['place_id'],
    'added_by' => $row['added_by'],
    'is_active' => $is_checked,
    'is_checked' => $is_active,
    'created_at' => $row['created_at'],
    'updated_at' => $row['updated_at'],
);
$conn->close();
$json = ['result' => true, 'event' => $event];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
