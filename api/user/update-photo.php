<?php

require_once('../error-handler.php');

function generateUniqueFilename($extension)
{
    $timestamp = round(microtime(true) * 1000);
    $random = mt_rand(100, 999);
    return $timestamp . '_' . $random . '.' . $extension;
}

function deleteImageFromServer($image_upload_path)
{
    if (file_exists($image_upload_path) && is_file($image_upload_path)) {
        if (unlink($image_upload_path)) {
            return true; // Файл успешно удален
        } else {
            return false; // Ошибка при удалении файла
        }
    }
    return true; // Файл уже отсутствует
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$user_id = isset($_POST["user_id"]) ? intval($_POST["user_id"]) : 0;
if ($user_id <= 0) {
    sendError('Invalid user ID.');
}

$session_key = isset($_POST["session_key"]) ? $_POST["session_key"] : '';
if (empty($session_key)) {
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

if (empty($_FILES['image']['name'])) {
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

require_once('../dbconfig.php');

$sql = "SELECT session_key, photo, created_at FROM User WHERE id = ?";
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
    sendError('Wrong key.');
}

$image_url = $row['photo']; // todo storred_image_url

if (!empty($image_url)) {
    $delete_path = "../../images/users/$image_url"; //TODO!
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete image from server.');
    }
}

$created_at = $row["created_at"];
$created_at_unix_timestamp = strtotime($created_at);
$created_year = date('Y', $created_at_unix_timestamp);
$created_month = date('m', $created_at_unix_timestamp);
$created_day = date('d', $created_at_unix_timestamp);

$photo_dir = "../../images/users/$created_year/$created_month/$created_day/$user_id/";
if (!file_exists($photo_dir)) {
    mkdir($photo_dir, 0777, true);
}
$image_name_unique = generateUniqueFilename($image_extension);
$image_upload_path = $photo_dir . $image_name_unique;
$image_path = "$created_year/$created_month/$created_day/$user_id/" . $image_name_unique;

if (!move_uploaded_file($_FILES['image']['tmp_name'], $image_upload_path)) {
    $conn->close();
    sendError('Failed to upload image.');
}

$sql = "UPDATE User SET photo = ? WHERE id = ?";
$params = [$image_path, $user_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update photo in User table.')) {
    $conn->close();
    $url = "https://www.navigay.me/images/users/" . $image_path;
    $json = ['result' => true, 'url' => $url];
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}
