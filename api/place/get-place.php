<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

require_once('../languages.php');

if (empty($_GET["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_GET["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, address, latitude, longitude, avatar, main_photo, photos, email, phone, www, facebook, instagram, about, tags, timetable, other_info, is_active, updated_at FROM Place WHERE id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$row = $result->fetch_assoc();

$is_active = (bool)$row['is_active'];

//todo на проверку
$tags_data = json_decode($row['tags'], true);
$timetable = json_decode($row['timetable'], true);

$photos_data = json_decode($row['photos'], true);
$photos_urls = array();
foreach ($photos_data as $photoItem) {
    $url_data = $photoItem['url'];
    if (isset($url_data) && is_string($url_data)) {
        $url = "https://www.navigay.me/" . $url_data;
        array_push($photos_urls, $url);
    }
}
$avatar = $row['avatar'];
$avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
$main_photo = $row['main_photo'];
$main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;

$place = array(
    'id' => $row['id'],
    'name' => $row["name"],
    'type_id' => $row['type_id'],
    'country_id' => $row['country_id'],
    'region_id' => $row['region_id'],
    'city_id' => $row['city_id'],
    'about' => $row['about'],
    'avatar' => $avatar_url,
    'main_photo' => $main_photo_url,
    'photos' => $photos_urls,
    'address' => $row['address'],
    'latitude' => $row['latitude'],
    'longitude' => $row['longitude'],
    'www' => $row['www'],
    'facebook' => $row['facebook'],
    'instagram' => $row['instagram'],
    'phone' => $row['phone'],
    'tags' => $tags_data,
    'timetable' => $timetable,
    'other_info' => $row['other_info'],
    'is_active' => $is_active,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE place_id = ?";
$sql .= " AND ((finish_date IS NOT NULL AND finish_date >= CURDATE() - INTERVAL 1 DAY) OR (finish_date IS NULL AND start_date >= CURDATE() - INTERVAL 1 DAY))";
$sql .= " AND is_active = true";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
$events = array();
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
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}
$place += ['events' => $events];

$conn->close();
$json = ['result' => true, 'place' => $place];
echo json_encode($json, JSON_NUMERIC_CHECK);
exit;
