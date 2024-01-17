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
$place_id = $data["place_id"];
if (!isset($place_id)) {
    sendError('place ID is required.');
}
$place_id = intval($place_id);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

$about = $data["about"];
$about = isset($about) ? mysqli_real_escape_string($conn, $about) : null;
$about = mysqli_real_escape_string($conn, $about);

$sql = "UPDATE Place SET about = ? WHERE id = ?";
$params = [$about, $place_id];
$types = "si";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update place table.')) {
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
