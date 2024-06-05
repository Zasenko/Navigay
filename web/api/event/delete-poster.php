<?php

require_once('../error-handler.php');
require_once('../img-helper.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}
$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    $conn->close();
    sendError('Invalid or empty request data.');
}

$event_id = isset($data["event_id"]) ? intval($data["event_id"]) : 0;
if ($event_id <= 0) {
    $conn->close();
    sendError('Invalid Event ID.');
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

$hashed_session_key = hash('sha256', $session_key);
$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
///--------------------------------------------
// ищем event
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
//----- удаляем фото
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

// обновляем
$sql = "UPDATE Event SET poster = null, poster_small = null WHERE id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update posters in place table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
