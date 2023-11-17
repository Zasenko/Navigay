<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$latitude = $_GET['latitude'];
$longitude = $_GET['longitude'];

if (!isset($latitude)) {
    sendError('Latitude is required.');
}
if (!isset($longitude)) {
    sendError('Longitude is required.');
}

$float_latitude = floatval($latitude);
$float_longitude = floatval($longitude);

require_once('../dbconfig.php');

$places = array();
$events = array();

$sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at FROM Place WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) <= 10 ";
$params = [$float_latitude, $float_longitude];
$types = "dd";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $tags = json_decode($row['tags'], true);
    $timetable = json_decode($row['timetable'], true);

    $avatar_url = "https://www.navigay.me/" . $row['avatar'];
    $poster_url = "https://www.navigay.me/" . $row['main_photo'];

    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'avatar' => $avatar_url,
        'main_photo' => $poster_url,
        'address' => $row['address'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
        'tags' => $tags,
        'timetable' => $timetable,
    );
    array_push($places, $place);
}

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) <= 20";
$params = [$float_latitude, $float_longitude];
$types = "dd";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_free = (bool)$row['is_free'];
    $tags = json_decode($row['tags'], true);

    $poster_url = "https://www.navigay.me/" . $row['poster'];
    $poster_small_url = "https://www.navigay.me/" . $row['poster_small'];

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
        //TODO [place]
        //'place_id' => $row['place_id'],
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}
$conn->close();
$json = ['result' => true, 'places' => $places, 'events' => $events];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
