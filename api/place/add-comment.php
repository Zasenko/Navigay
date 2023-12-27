<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedComment = json_decode($postData, true);
if (empty($decodedComment)) {
    sendError('Empty Data.');
}

$place_id = $decodedComment["place_id"];
$user_id = $decodedComment["user_id"];
$comment = $decodedComment["comment"];
$rating = $decodedComment["rating"];

// TODO!!!! USER ID проверить в базе!

if (!isset($place_id) || !isset($user_id)) {
    sendError('place id and user id is required.');
}
$rating = !isset($rating) ? intval($rating) : null;

require_once('../dbconfig.php');

$sql = "INSERT INTO PlaceComment (place_id, user_id, comment, rating) VALUES (?, ?, ?, ?)";
$params = [$place_id, $user_id, $comment, $rating];
$types = "iisi";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Place table.')) {
    $comment_id = getLastInsertId($conn);
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
