<?php

require_once('../../api/error-handler.php');
require_once('../../api/languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (!isset($_GET["city_id"]) || !is_numeric($_GET["city_id"])) {
    sendError('Invalid or missing "id" parameter.');
}

$city_id = (int)$_GET["city_id"];

$user_date = $_GET['date'];
if (!isset($user_date)) {
    sendError('Date is required.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../../api/dbconfig.php');

$sql = "SELECT id, name, type_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, updated_at FROM Event WHERE city_id = ? AND is_active = true AND ((finish_date IS NULL AND start_date = ?) OR (finish_date IS NOT NULL AND finish_date > ? AND start_date <= ?))";

$params = [$city_id, $user_date, $user_date, $user_date];
$types = "isss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$events = array();
while ($row = $result->fetch_assoc()) {

    $is_free = (bool)$row['is_free'];
    $tags = json_decode($row['tags'], true);

    $poster_small = $row['poster_small'];
    $poster_small_url = isset($poster_small) ? "https://www.navigay.me/" . $poster_small : null;

    $poster = $row['poster'];
    $poster_url = isset($poster) ? "https://www.navigay.me/" . $poster : null;

    $event = array(
        "id" => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'address' => $row['address'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'start_date' => $row['start_date'],
        'start_time' => $row['start_time'],
        'finish_date' => $row['finish_date'],
        'finish_time' => $row['finish_time'],
        'tags' => $tags,
        'location' => $row['location'],
        'poster' => $poster_url,
        'poster_small' => $poster_small_url,
        'is_free' => $is_free,
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}
$conn->close();
$json = array('result' => true, 'events' => $events);
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
