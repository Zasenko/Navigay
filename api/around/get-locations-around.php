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

$sql = "SELECT
    id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at
FROM
    Place
WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20";
$params = [$float_latitude, $float_longitude];
$types = "dd";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $tags = json_decode($row['tags'], true);
    $timetable = json_decode($row['timetable'], true);

    $avatar = $row['avatar'];
    $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;

    $main_photo = $row['main_photo'];
    $main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;

    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'avatar' => $avatar_url,
        'main_photo' => $main_photo_url,
        'address' => $row['address'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'tags' => $tags,
        'timetable' => $timetable,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}

if (empty($places)) {
    $sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at, SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 AS distance FROM Place ORDER BY distance ASC LIMIT 5";
    $params = [$float_latitude, $float_longitude];
    $types = "dd";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $result = $stmt->get_result();
    $stmt->close();

    while ($row = $result->fetch_assoc()) {
        $is_active = (bool)$row['is_active'];
        $tags = json_decode($row['tags'], true);
        $timetable = json_decode($row['timetable'], true);

        $avatar = $row['avatar'];
        $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;

        $main_photo = $row['main_photo'];
        $main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;

        $place = array(
            'id' => $row['id'],
            'name' => $row["name"],
            'type_id' => $row['type_id'],
            'avatar' => $avatar_url,
            'main_photo' => $main_photo_url,
            'address' => $row['address'],
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'tags' => $tags,
            'timetable' => $timetable,
            'is_active' => $is_active,
            'updated_at' => $row['updated_at'],
        );
        array_push($places, $place);
    }
}

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20";
$params = [$float_latitude, $float_longitude];
$types = "dd";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
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
