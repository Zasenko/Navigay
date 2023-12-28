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
$photos = $decodedComment['photos'];
$photos = isset($decodedComment["photos"]) ? $decodedComment["photos"] : [];

if (!isset($place_id) || !isset($user_id)) {
    sendError('place id and user id is required.');
}
$rating = isset($rating) ? intval($rating) : null;

require_once('../dbconfig.php');

$sql = "SELECT id FROM User WHERE id = ? AND status <> 'blocked'";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('User with id ' . $user_id . ' not found or user is blocked.');
}

$sql = "SELECT Place.id, Country.isoCountryCode FROM Place INNER JOIN Country ON Place.country_id = Country.id  WHERE Place.id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if ($result->num_rows === 0) {
    $conn->close();
    sendError('Place with id ' . $place_id . ' not found.');
}
$row = $result->fetch_assoc();
$place_id = $row['id'];
$isoCountryCode = $row['isoCountryCode'];


$sql = "INSERT INTO PlaceComment (place_id, user_id, comment, rating) VALUES (?, ?, ?, ?)";
$params = [$place_id, $user_id, $comment, $rating];
$types = "iisi";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to insert data (place id: ' . $place_id . ', user id: ' . $user_id . ', comment: ' . $comment . ', rating: ' . $rating . ') into Comment table.')) {

    $comment_id = getLastInsertId($conn);
    $uploadDir = "../../images/places/$isoCountryCode/$place_id/comments/";
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    $photoLinks = [];
    foreach ($photos as $photo) {
        $photoData = base64_decode($photo); // Assuming the image data is base64 encoded

        if (strlen($photoData) > (5 * 1024 * 1024)) { // 5 MB limit
            $conn->close();
            sendError('Image size exceeds the limit.');
        }

        $photoFileName = uniqid() . ".jpg"; // You can use a more robust naming convention
        $photoPath = $uploadDir . $photoFileName;

        file_put_contents($photoPath, $photoData);

        $fileHandle = fopen($photoPath, 'wb');
        if ($fileHandle) {
            fwrite($fileHandle, $photoData);
            fclose($fileHandle);
            $image_path = "images/places/$isoCountryCode/$place_id/comments/" . $photoFileName;
            $photoLinks[] = $image_path;
        } else {
            $conn->close();
            sendError('Unable to open file for writing.');
        }
    }
    if (!empty($photoLinks)) {
        $photoLinksJson = json_encode($photoLinks, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
        sendError("Debug: photoLinksJson: " . $photoLinksJson);
        $sql = "UPDATE PlaceComment SET photos = ? WHERE id = ?";
        $params = [$photoLinksJson, $comment_id];
        $types = "si";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to add photos links into Place table.')) {
            $conn->close();
            $json = ['result' => true];
            echo json_encode($json);
            exit;
        }
    }
    $conn->close();
    $json = ['result' => true];
    echo json_encode($json);
    exit;
}
