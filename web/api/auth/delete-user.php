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

$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
if ($user_id <= 0) {
    sendError('Invalid user ID.');
}

$session_key = isset($data["session_key"]) ? $data["session_key"] : '';
if (empty($session_key)) {
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);


require_once('../dbconfig.php');

$sql = "SELECT session_key, photo, created_at FROM User WHERE id = ?";
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
    sendError('Wrong key.');
}
//--------

$image_url = $row['photo'];

// Delete user's photo folder if exists
if (!empty($image_url)) {
    $delete_path = "../../images/users/$image_url";

    // Delete the photo file
    if (file_exists($delete_path)) {
        if (!unlink($delete_path)) {
            $conn->close();
            sendError('Failed to delete user photo.');
        }
    } else {
        $conn->close();
        sendError('User photo not found on the server.');
    }

    // Delete the folder if it's empty after deleting the photo
    $folder_path = dirname($delete_path);
    if (is_dir($folder_path) && count(scandir($folder_path)) == 2) {
        if (!rmdir($folder_path)) {
            $conn->close();
            sendError('Failed to delete user photo directory.');
        }
    }
}

// Delete user from database
$sql_delete_user = "DELETE FROM User WHERE id = ?";
$stmt_delete_user = executeQuery($conn, $sql_delete_user, [$user_id], "i");
if (!$stmt_delete_user) {
    $conn->close();
    sendError('Failed to delete user from database.');
}

// Close connection
$conn->close();

$json = ['result' => true];
echo json_encode($json);
exit;
