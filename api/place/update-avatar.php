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

if (empty($_POST["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_POST["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

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

$sql = "SELECT Place.avatar as avatar, Country.isoCountryCode as isoCountryCode FROM Place INNER JOIN Country ON Country.id = Place.country_id WHERE Place.id = ?";
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
$isoCountryCode = $row['isoCountryCode'];
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code in Place with id' . $place_id . ' is empty.');
}
$image_url = $row['avatar'];

if (!empty($image_url)) {
    $delete_path = "../../$image_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete image from server.');
    }
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

$sql = "UPDATE Place SET avatar = ? WHERE id = ?";
$params = [$image_path, $place_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update avatar photo in place table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $json = ['result' => true, 'url' => $url];
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
