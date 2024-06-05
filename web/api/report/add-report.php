<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$decodedReport = json_decode($postData, true);

if (empty($decodedReport)) {
    sendError('Empty Data.');
}

$item = intval($decodedReport["item"]);
$itemId = intval($decodedReport["itemId"]);
$reason = intval($decodedReport["reason"]);
$text = isset($decodedReport["text"]) ? $decodedReport["text"] : null;
$userId = isset($decodedReport['userId']) ? intval($decodedReport['userId']) : null;

// добавить репорт
require_once('../dbconfig.php');

$sql = "INSERT INTO Report (item, itemId, reason, text, userId) VALUES (?, ?, ?, ?, ?)";
$params = [$item, $itemId, $reason, $text, $userId];
$types = "iiisi";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data into Report table.')) {
    switch ($item) {
    case 1:// comment
        $sql = "UPDATE PlaceComment SET is_active = false, is_checked = false WHERE id = ?";
        $params = [$itemId];
        $types = "i";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to update comment status.')) {
            $conn->close();
            $json = ['result' => true];
            echo json_encode($json);
        }
        break;
    default:
        break;
    }
}
exit;
