<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (empty($_GET["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_GET["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

require_once('../dbconfig.php');

$sql = "SELECT pc.id, pc.comment, pc.rating, pc.photos, pc.created_at, pc.is_active, pcr.id AS reply_id, pcr.comment AS reply_text, pcr.created_at AS reply_created_at, pc.is_active AS reply_is_active
FROM PlaceComment pc
    LEFT JOIN PlaceCommentReply pcr ON pc.id = pcr.comment_id
    WHERE pc.place_id = ?
    ORDER BY pc.created_at DESC, pcr.created_at ASC
";

$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
$comments = array();

while ($row = $result->fetch_assoc()) {
    //todo на проверку
    $is_active = (bool)$row['is_active'];

    $photos_data = json_decode($row['photos'], true);
    $photos_urls = array();
    foreach ($photos_data as $photoItem) {
        $url_data = $photoItem['url'];
        if (isset($url_data) && is_string($url_data)) {
            $url = "https://www.navigay.me/" . $url_data;
            array_push($photos_urls, $url);
        }
    }

    $comment = array(
        "id" => $row['id'],
        'comment' => $row["comment"],
        'rating' => $row['rating'],
        'photos' => $photos_urls,
        'created_at' => $row['created_at'],
        'is_active' => $is_active,
    );

    $reply_is_active = (bool)$row['reply_is_active'];
    $reply = array(
        "id" => $row['reply_id'],
        'comment' => $row["reply_text"],
        'created_at' => $row['reply_created_at'],
        'is_active' => $reply_is_active,
    );
    $comment += ['reply' => $reply];
    array_push($comments, $comment);
}
$conn->close();
$json = ['result' => true, 'comments' => $comments];
echo json_encode($json, JSON_NUMERIC_CHECK);
exit;
