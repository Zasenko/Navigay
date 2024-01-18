<?php

require_once('../error-handler.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);

if (empty($data)) {
    sendError('Empty Data.');
}
$event_id = $data["event_id"];
if (!isset($event_id)) {
    sendError('event ID is required.');
}
$event_id = intval($event_id);
if ($event_id <= 0) {
    sendError('Invalid event ID.');
}

$about = $data["about"];
$about = isset($about) ? $about : null;

$sql = "UPDATE Event SET about = ? WHERE id = ?";
$params = [$about, $event_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update event table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
