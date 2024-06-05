<?php

require_once('../error-handler.php');
require_once('../img-helper.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}
if (empty($_POST["country_id"])) {
    $conn->close();
    sendError('Country ID is required.');
}
$country_id = intval($_POST["country_id"]);
if ($country_id <= 0) {
    $conn->close();
    sendError('Invalid country ID.');
}

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
$user_status = isset($row['status']) ? $row['status'] : '';
if (!($user_status === "admin" || $user_status === "moderator")) {
    $conn->close();
    sendError('Admin access only.');
}
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

$sql = "SELECT id, photo FROM Country WHERE id = ?";
$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('Country with id ' . $country_id . ' not found.');
}

$row = $result->fetch_assoc();
$image_url = $row['photo'];

if (!empty($image_url)) {
    $delete_path = "../../$image_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete image from server.');
    }
}

$photo_dir = "../../images/countries/$country_id/";
if (!file_exists($photo_dir)) {
    mkdir($photo_dir, 0777, true);
}
$image_name_unique = generateUniqueFilename($image_extension);
$image_upload_path = $photo_dir . $image_name_unique;
$image_path = "images/countries/$country_id/" . $image_name_unique;

if (!move_uploaded_file($_FILES['image']['tmp_name'], $image_upload_path)) {
    $conn->close();
    sendError('Failed to upload image.');
}

$sql = "UPDATE Country SET photo = ? WHERE id = ?";
$params = [$image_path, $country_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update photo in country table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $json = ['result' => true, 'url' => $url];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
