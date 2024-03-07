<?php

require_once('../error-handler.php');
require_once('../img-helper.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$event_id = isset($_POST["event_id"]) ? intval($_POST["event_id"]) : 0;
if ($event_id <= 0) {
    sendError('Invalid event ID.');
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

//-------- проверка юзера
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
if (!($user_status === "admin" || $user_status === "moderator" || $user_status === "partner")) {
    $conn->close();
    sendError('Admin access only.');
}
$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}

//---------- photos
if (!isset($_FILES['poster']['tmp_name']) || !file_exists($_FILES['poster']['tmp_name'])) {
    $conn->close();
    sendError('The poster file does not exist.');
}
if (!isset($_FILES['small_poster']['tmp_name']) || !file_exists($_FILES['small_poster']['tmp_name'])) {
    $conn->close();
    sendError('The small poster file does not exist.');
}
if (empty($_FILES['poster']['name'])) {
    $conn->close();
    sendError('poster file is required.');
}
if (empty($_FILES['small_poster']['name'])) {
    $conn->close();
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

$sql = "SELECT poster, poster_small, added_by, created_at FROM Event WHERE id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if (!($result->num_rows > 0)) {
    $conn->close();
    sendError('Event with id: ' . $event_id . ' not found in the database');
}
$row = $result->fetch_assoc();

// проверка юзера, который добавлял или админа
if (!($user_status === "admin" || $user_status === "moderator")) {
    $added_by = $row['added_by'];
    if (!($user_id === $added_by)) {
        $conn->close();
        sendError('You do not have rights to change data.');
    }
}
// создаем изображение
$created_at = $row["created_at"];
$created_at_unix_timestamp = strtotime($created_at);
$created_year = date('Y', $created_at_unix_timestamp);
$created_month = date('m', $created_at_unix_timestamp);
$created_day = date('d', $created_at_unix_timestamp);

$photo_dir = "../../images/events/$created_year/$created_month/$created_day/$event_id/";
if (!file_exists($photo_dir)) {
    // todo ! Добавить во все файлы
    if (!mkdir($photo_dir, 0777, true)) {
        $conn->close();
        sendError('Failed to create photo directory.');
    }
}

$poster_name_unique = generateUniqueFilename($poster_extension);
$small_poster_name_unique = generateUniqueFilename($small_poster_extension);

$poster_upload_path = $photo_dir . $poster_name_unique;
$small_poster_upload_path = $photo_dir . $small_poster_name_unique;

$poster_path = "images/events/$created_year/$created_month/$created_day/$event_id/" . $poster_name_unique;
$small_poster_path = "images/events/$created_year/$created_month/$created_day/$event_id/" . $small_poster_name_unique;

if (!move_uploaded_file($_FILES['poster']['tmp_name'], $poster_upload_path)) {
    $conn->close();
    sendError('Failed to upload poster.');
}
if (!move_uploaded_file($_FILES['small_poster']['tmp_name'], $small_poster_upload_path)) {
    $conn->close();
    sendError('Failed to upload small poster.');
}

//----- удаляем предыдущие
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

//-обновляем
$sql = "UPDATE Event SET poster = ?, poster_small = ? WHERE id = ?";
$params = [$poster_path, $small_poster_path, $event_id];
$types = "ssi";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update posters in place table.')) {
    $conn->close();

    $poster_url = "https://www.navigay.me/" . $poster_path;
    $small_poster_url = "https://www.navigay.me/" . $small_poster_path;

    $poster = array(
        "poster_url" => $poster_url,
        'small_poster_url' => $small_poster_url,
    );
    $json = ['result' => true, 'poster' => $poster];
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
