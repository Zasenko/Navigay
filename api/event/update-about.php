<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    sendError('Invalid or empty request data.');
}

$event_id = isset($data["event_id"]) ? intval($data["event_id"]) : 0;
if ($event_id <= 0) {
    $conn->close();
    sendError('Invalid event ID.');
}

$about = isset($data["about"]) ? $data["about"] : null;

require_once('../dbconfig.php');

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

$sql = "SELECT id, owner_id FROM Event WHERE id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$event_result = $stmt->get_result();
$stmt->close();

if ($event_result->num_rows === 0) {
    $conn->close();
    sendError('Event with id ' . $event_id . ' not found');
}
$row = $event_result->fetch_assoc();

// проверка юзера, который добавлял или админа
if (!($user_status === "admin" || $user_status === "moderator" || ($user_id === intval($row['owner_id']) && $row['owner_id'] !== null))) {
    sendUserError('You do not have enough access rights to change data.');
}

$sql = "UPDATE Event SET about = ? WHERE id = ?";
$params = [$about, $event_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update about in Event table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
