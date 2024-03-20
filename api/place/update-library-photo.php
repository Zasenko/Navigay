<?php

require_once('../error-handler.php');
require_once('../img-helper.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

if (empty($_POST["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_POST["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

$photo_id = $_POST["photo_id"];
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

if (empty($_FILES['image']['name'])) {
    $conn->close();
    sendError('Image file is required.');
}

$allowed_extensions = ['jpeg', 'jpg', 'png'];
$max_file_size = 5 * 1024 * 1024; // 5 MB
$image_extension = strtolower(pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION));
$image_size = $_FILES['image']['size'];
if (!in_array($image_extension, $allowed_extensions)) {
    sendUserError('Invalid image format. Allowed formats: JPEG, JPG, PNG.');
}
if ($image_size > $max_file_size) {
    sendUserError('Image size is too large. Max file size is 5 MB.');
}

$sql = "SELECT Place.id, Country.isoCountryCode as isoCountryCode, Place.photos, Place.owner_id FROM Place INNER JOIN Country ON Country.id = Place.country_id WHERE Place.id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$place_result = $stmt->get_result();
$stmt->close();

if ($place_result->num_rows === 0) {
    $conn->close();
    sendError('Place with id ' . $place_id . ' not found');
}
$row = $place_result->fetch_assoc();

// проверка юзера, который добавлял или админа
if (!($user_status === "admin" || $user_status === "moderator" || ($user_id === intval($row['owner_id']) && $row['owner_id'] !== null))) {
    sendUserError('You do not have enough access rights to change data.');
}

$photos_json = json_decode($row['photos'], true);
$isoCountryCode = $row['isoCountryCode'];

if (!is_array($photos_json)) {
    $photos_json = [];
}
if (count($photos_json) >= 9) {
    $conn->close();
    sendUserError('The maximum number of photos is 9.');
}
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code in Place with id' . $place_id . ' is empty.');
}

$photo_dir = "../../images/places/$isoCountryCode/$place_id/";
if (!file_exists($photo_dir)) {
    mkdir($photo_dir, 0777, true);
}
$image_name_unique = generateUniqueFilename($image_extension);
$image_upload_path = $photo_dir . $image_name_unique;
$image_path = "images/places/$isoCountryCode/$place_id/" . $image_name_unique;

if (!move_uploaded_file($_FILES['image']['tmp_name'], $image_upload_path)) {
    $conn->close();
    sendError('Failed to upload image.');
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

if ($image_url !== null) {
    if (!empty($image_url)) {
        $delete_path = "../../$image_url";
        if (!deleteImageFromServer($delete_path)) {
            $conn->close();
            sendError('Failed to delete image from server.');
        }
    }
}

if ($image_index !== null) {
    unset($photos_json[$image_index]);
}

$json_data = [
    'id' => $photo_id,
    'url' => $image_path,
];
$photos_json[] = $json_data;

$updated_photos_json = json_encode(array_values($photos_json), JSON_UNESCAPED_UNICODE);

$sql = "UPDATE Place SET photos = ? WHERE id = ?";
$params = [$updated_photos_json, $place_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to update photos data into Place table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $json = ['result' => true, 'url' => $url];
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}
