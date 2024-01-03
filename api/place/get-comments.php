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

$sql = "SELECT
pc.id,
pc.comment,
pc.rating,
pc.photos,
pc.created_at,
pc.is_active,
u.id AS user_id,
u.name AS user_name,
u.bio AS user_bio,
u.photo AS user_photo,
pcr.id AS reply_id,
pcr.comment AS reply_text,
pcr.created_at AS
reply_created_at,
pc.is_active AS reply_is_active
FROM PlaceComment pc
    LEFT JOIN User u ON pc.user_id = u.id
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

    $photos_path = json_decode($row['photos'], true);
    $photos_urls = array();
    foreach ($photos_path as $photo_path) {
        $url = "https://www.navigay.me/" . $photo_path;
        array_push($photos_urls, $url);
    }

    $comment = array(
        "id" => $row['id'],
        'comment' => $row["comment"],
        'rating' => $row['rating'],
        'photos' => $photos_urls,
        'created_at' => $row['created_at'],
        'is_active' => $is_active,
    );

    $reply_id = $row['reply_id'];
    $reply_text = $row['reply_id'];
    $reply_created_at = $row['reply_created_at'];
    $reply_is_active = (bool)$row['reply_is_active'];
    if (isset($reply_id) || isset($reply_text) || isset($reply_created_at)) {
        $reply = array(
            "id" => $reply_id,
            'comment' => $reply_text,
            'created_at' => $reply_created_at,
            'is_active' => $reply_is_active,
        );
        $comment += ['reply' => $reply];
    }
    $user_photo = $row['user_photo'];
    $user_photo_url = isset($user_photo) ? "https://www.navigay.me/" . $user_photo : null;

    $user = array(
        "id" => $row['user_id'],
        'bio' => $row["user_bio"],
        'name' => $row["user_name"],
        'photo' => $user_photo_url
    );
    $comment += ['user' => $user];
    array_push($comments, $comment);
}
$conn->close();
$json = ['result' => true, 'comments' => $comments];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
