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

$city_id = isset($data["city_id"]) ? intval($data["city_id"]) : 0;
if ($city_id <= 0) {
    $conn->close();
    sendError('Invalid city ID.');
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


$sql = "SELECT * FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('User not found.');
}

$row = $result->fetch_assoc();

$is_active = (bool)$row['is_active'];
$is_checked = (bool)$row['is_checked'];

$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

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
$city = array(
    'id' => $row['id'],
    'country_id' => $row["country_id"],
    'region_id' => $row['region_id'],
    'name_origin_en' => $row['name_origin_en'],
    'name_en' => $row['name_en'],
    'about' => $row['about'],
    'photo' => $photo_url,
    'photos' => $library_photos,
    'redirect_city_id' => $row['redirect_city_id'],
    'is_active' => $is_active,
    'is_checked' => $is_checked,
);
$conn->close();
$json = ['result' => true, 'city' => $city];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
