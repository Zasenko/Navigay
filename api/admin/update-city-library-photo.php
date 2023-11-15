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

if (empty($_POST["id"])) {
    sendError('City ID are required.');
}
$city_id = intval($_POST["id"]);
if ($city_id <= 0) {
    sendError('Invalid city ID.');
}

$photo_id = $_POST["photo_id"];
if (empty($photo_id)) {
    sendError('Invalid photo ID.');
}
$photo_id = trim($photo_id);

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

$sql = "SELECT id, photos FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$place_result = $stmt->get_result();
$stmt->close();

if ($place_result->num_rows === 0) {
    $conn->close();
    sendError('City with id ' . $city_id . ' not found.');
}

$row = $place_result->fetch_assoc();
$photos_json = json_decode($row['photos'], true);

if (!is_array($photos_json)) {
    $photos_json = [];
}
if (count($photos_json) >= 9) {
    $conn->close();
    sendUserError('The maximum number of photos is 9.');
}
$photo_dir = "../../images/cities/$city_id/";
if (!file_exists($photo_dir)) {
    mkdir($photo_dir, 0777, true);
}
$image_name_unique = generateUniqueFilename($image_extension);
$image_upload_path = $photo_dir . $image_name_unique;
$image_path = "images/cities/$city_id/" . $image_name_unique;

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

$updated_photos_json = json_encode(array_values($photos_json), JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
$sql = "UPDATE City SET photos = ? WHERE id = ?";
$params = [$updated_photos_json, $city_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to update photos data into City table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $json = ['result' => true, 'url' => $url];
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
