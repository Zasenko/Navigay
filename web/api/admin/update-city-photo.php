<?php

require_once('../error-handler.php');
require_once('../img-helper.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}

if (empty($_POST["city_id"])) {
    $conn->close();
    sendError('City ID is required.');
}
$city_id = intval($_POST["city_id"]);
if ($city_id <= 0) {
    $conn->close();
    sendError('Invalid city ID.');
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
if (empty($_FILES['small_image']['name'])) {
    $conn->close();
    sendError('small image file is required.');
}
if (!isset($_FILES['image']['tmp_name']) || !file_exists($_FILES['image']['tmp_name'])) {
    $conn->close();
    sendError('The image file does not exist.');
}
if (!isset($_FILES['small_image']['tmp_name']) || !file_exists($_FILES['small_image']['tmp_name'])) {
    $conn->close();
    sendError('The small image file does not exist.');
}




$allowed_extensions = ['jpeg', 'jpg', 'png'];
$max_file_size = 5 * 1024 * 1024; // 5 MB

$image_extension = strtolower(pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION));
$small_image_extension = strtolower(pathinfo($_FILES['small_image']['name'], PATHINFO_EXTENSION));

$image_size = $_FILES['image']['size'];
$small_image_size = $_FILES['small_image']['size'];

if (!in_array($image_extension, $allowed_extensions)) {
    sendUserError('Invalid image format. Allowed formats: JPEG, JPG, PNG.');
}
if (!in_array($small_image_extension, $allowed_extensions)) {
    sendUserError('Invalid small image format. Allowed formats: JPEG, JPG, PNG.');
}
if ($image_size > $max_file_size) {
    sendUserError('Image size is too large. Max file size is 5 MB.');
}
if ($small_image_size > $max_file_size) {
    sendUserError('Small image size is too large. Max file size is 5 MB.');
}


$sql = "SELECT id, small_photo, photo FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('City with id ' . $city_id . ' not found.');
}

$row = $result->fetch_assoc();
$image_url = $row['photo'];

$photo_dir = "../../images/cities/$city_id/";

if (!file_exists($photo_dir)) {
    if (!mkdir($photo_dir, 0777, true)) {
        $conn->close();
        sendError('Failed to create photo directory.');
    }
}

$image_name_unique = generateUniqueFilename($image_extension);
$small_image_name_unique = generateUniqueFilename($small_image_extension);

$image_upload_path = $photo_dir . $image_name_unique;
$small_image_upload_path = $photo_dir . $small_image_name_unique;

$image_path = "images/cities/$city_id/" . $image_name_unique;
$small_image_path = "images/cities/$city_id/" . $small_image_name_unique;

if (!move_uploaded_file($_FILES['image']['tmp_name'], $image_upload_path)) {
    $conn->close();
    sendError('Failed to upload image.');
}
if (!move_uploaded_file($_FILES['small_image']['tmp_name'], $small_image_upload_path)) {
    $conn->close();
    sendError('Failed to upload small image.');
}

//----- удаляем предыдущие
if (!empty($image_url)) {
    $delete_path = "../../$image_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete image from server.');
    }
}
if (!empty($small_image_url)) {
    $delete_path = "../../$small_image_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete small image from server.');
    }
}

$sql = "UPDATE City SET small_photo = ?, photo = ? WHERE id = ?";
$params = [$small_image_path, $image_path, $city_id];
$types = "ssi";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update photo and small photo in city table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $url_small_img = "https://www.navigay.me/" . $small_image_path;
    $poster = array(
        "poster_url" => $url,
        'small_poster_url' => $url_small_img,
    );
    $json = ['result' => true, 'poster' => $poster];
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}
