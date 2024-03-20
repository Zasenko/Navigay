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
$place_id = isset($data["place_id"]) ? intval($data["place_id"]) : 0;
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

$email = isset($data["email"]) ? $data["email"] : null;
$phone = isset($data["phone"]) ? $data["phone"] : null;
$www = isset($data["www"]) ? $data["www"] : null;
$facebook = isset($data["facebook"]) ? $data["facebook"] : null;
$instagram = isset($data["instagram"]) ? $data["instagram"] : null;
$other_info = isset($data["other_info"]) ? $data["other_info"] : null;

$tags = isset($data["tags"]) ? json_decode($data["tags"], true) : null;
$tags_json = $tags !== null ? json_encode($tags) : null;

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

$sql = "SELECT id, owner_id FROM Place WHERE id = ?";
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

$sql = "UPDATE Place SET email = ?, phone = ?, www = ?, facebook = ?, instagram = ?, other_info = ?, tags = ? WHERE id = ?";
$params = [$email, $phone, $www, $facebook, $instagram, $other_info, $tags_json, $place_id];
$types = "sssssssi";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update about in place table.')) {
    $conn->close();
    $url = "https://www.navigay.me/" . $image_path;
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
