<?php

require_once('../error-handler.php');

function generateUniqueFilename($extension)
{
    $timestamp = round(microtime(true) * 1000);
    $random = mt_rand(100, 999);
    return $timestamp . '_' . $random . '.' . $extension;
}
function deleteImageFromServer($poster_upload_path)
{
    if (file_exists($poster_upload_path) && is_file($poster_upload_path)) {
        if (unlink($poster_upload_path)) {
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

if (empty($_POST["event_id"])) {
    sendError('Place ID are required.');
}
$event_id = intval($_POST["event_id"]);
if ($event_id <= 0) {
    sendError('Invalid place ID.');
}

if (empty($_FILES['poster']['name'])) {
    sendError('poster file is required.');
}
if (empty($_FILES['small_poster']['name'])) {
    sendError('Small poster file is required.');
}

$allowed_extensions = ['jpeg', 'jpg', 'png'];
$max_file_size = 5 * 1024 * 1024; // 5 MB

$poster_extension = strtolower(pathinfo($_FILES['poster']['name'], PATHINFO_EXTENSION));
$small_poster_extension = strtolower(pathinfo($_FILES['small_poster']['name'], PATHINFO_EXTENSION));

$poster_size = $_FILES['poster']['size'];
$small_poster_size = $_FILES['small_poster']['size'];
if (!in_array($poster_extension, $allowed_extensions)) {
    sendUserError('Invalid poster format. Allowed formats: JPEG, JPG, PNG.');
}
if (!in_array($small_poster_extension, $allowed_extensions)) {
    sendUserError('Invalid small poster format. Allowed formats: JPEG, JPG, PNG.');
}
if ($poster_size > $max_file_size) {
    sendUserError('Poster size is too large. Max file size is 5 MB.');
}
if ($small_poster_size > $max_file_size) {
    sendUserError('Small poster size is too large. Max file size is 5 MB.');
}
require_once('../dbconfig.php');

$sql = "SELECT Event.poster as poster, Event.poster_small as poster_small, Country.isoCountryCode as isoCountryCode FROM Event INNER JOIN Country ON Country.id = Event.country_id WHERE Event.id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('Event with id ' . $event_id . ' not found');
}

$row = $result->fetch_assoc();
$isoCountryCode = $row['isoCountryCode'];
if (!isset($isoCountryCode)) {
    $conn->close();
    sendError('ISO country code in Event with id' . $event_id . ' is empty.');
}
$poster_url = $row['poster'];
$small_poster_url = $row['poster_small'];

if (!empty($poster_url)) {
    $delete_path = "../../$poster_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete poster from server.');
    }
}
if (!empty($small_poster_url)) {
    $delete_path = "../../$small_poster_url";
    if (!deleteImageFromServer($delete_path)) {
        $conn->close();
        sendError('Failed to delete small poster from server.');
    }
}

$photo_dir = "../../images/events/$isoCountryCode/$event_id/";
if (!file_exists($photo_dir)) {
    mkdir($photo_dir, 0777, true);
}
$poster_name_unique = generateUniqueFilename($poster_extension);
$small_poster_name_unique = generateUniqueFilename($small_poster_extension);

$poster_upload_path = $photo_dir . $poster_name_unique;
$small_poster_upload_path = $photo_dir . $small_poster_name_unique;


$poster_path = "images/events/$isoCountryCode$event_id/" . $poster_name_unique;
$small_poster_path = "images/events/$isoCountryCode$event_id/" . $small_poster_name_unique;

if (!move_uploaded_file($_FILES['poster']['tmp_name'], $poster_upload_path)) {
    $conn->close();
    sendError('Failed to upload poster.');
}
if (!move_uploaded_file($_FILES['small_poster']['tmp_name'], $small_poster_upload_path)) {
    $conn->close();
    sendError('Failed to upload small poster.');
}

$sql = "UPDATE Event SET poster = ?, poster_small = ? WHERE id = ?";
$params = [$poster_path, $small_poster_path, $event_id];
$types = "ssi";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update posters in place table.')) {
    $conn->close();
    $poster_url = "https://www.navigay.me/" . $poster_path;
    $small_poster_url = "https://www.navigay.me/" . $small_poster_path;
    $json = ['result' => true, 'poster_url' => $poster_url, 'small_poster_url' => $small_poster_path];
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
