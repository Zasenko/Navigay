<?php

require_once('../error-handler.php');
require_once('../img-helper.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    sendError('Invalid or empty request data. Please make sure to submit valid JSON data.');
}

$place_id = intval($data["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

$photo_id = $data["photo_id"];
if (empty($photo_id)) {
    sendError('Invalid photo ID.');
}
$photo_id = trim($photo_id);

require_once('../dbconfig.php');

//-------- проверка юзера
$user_id = isset($_POST["user_id"]) ? intval($_POST["user_id"]) : 0;
if ($user_id <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($_POST["session_key"]) ? $_POST["session_key"] : '';
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

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
$user_status = $row['status'];
//-----------------

$sql = "SELECT id, photos FROM Place WHERE id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$place_result = $stmt->get_result();
$stmt->close();

if ($place_result->num_rows === 0) {
    $conn->close();
    sendError('Place with id ' . $place_id . ' not found.');
}
$row = $place_result->fetch_assoc();
$photos_json = json_decode($row['photos'], true);

if (!is_array($photos_json)) {
    $photos_json = [];
}

$image_index = null;
$image_url = null;

foreach ($photos_json as $index => $photo) {
    if ($photo['id'] === $photo_id) {
        $image_index = $index;
        $image_url = $photo['url'] ?? null;
        break;
    }
}

if ($image_url === null || empty($image_url) || $image_index === null) {
    $conn->close();
    sendError('Image URL with ID ' . $photo_id . ' in place with ID ' . $place_id . ' not found in the database.');
}
$delete_path = "../../$image_url";

if (!deleteImageFromServer($delete_path)) {
    $conn->close();
    sendError('Failed to delete image from server.');
}

unset($photos_json[$image_index]);

$photos_json = array_values($photos_json);
$updated_photos_json = json_encode($photos_json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);

$sql = "UPDATE Place SET photos = ? WHERE id = ?";
$params = [$updated_photos_json, $place_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update photos data into Place table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
