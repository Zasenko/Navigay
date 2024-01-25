<?php

require_once('../error-handler.php');
require_once('../languages.php');


if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}
$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

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

$user_date = $_GET['user_date'];
if (!isset($user_date)) {
    sendError('Date is required.');
}
require_once('../dbconfig.php');

$places = array();
$events = array();

$sql = "SELECT id, name, type_id, city_id, avatar, main_photo, address, latitude, longitude, tags, timetable, updated_at FROM Place WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20 AND is_active = true";
$params = [$float_latitude, $float_longitude];
$types = "dd";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
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
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}

$sql = "SELECT id, name, type_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20 AND is_active = true AND ((finish_date IS NULL AND start_date >= ?) OR (finish_date IS NOT NULL AND finish_date >= ?))";

$params = [$float_latitude, $float_longitude, $user_date, $user_date];
$types = "ddss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

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
        //TODO [place]
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}

$found_around = true;

if (empty($places) && empty($events)) {

    $found_around = false;

    $sql = "SELECT id, name, type_id, city_id, avatar, main_photo, address, latitude, longitude, tags, timetable, updated_at, SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 AS distance FROM Place WHERE is_active = true ORDER BY distance ASC LIMIT 5";
    $params = [$float_latitude, $float_longitude];
    $types = "dd";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $result = $stmt->get_result();
    $stmt->close();

    while ($row = $result->fetch_assoc()) {
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
            'city_id' => $row['city_id'],
            'updated_at' => $row['updated_at'],
        );
        array_push($places, $place);
    }
}

$items = array(
    'found_around' => $found_around,
    'places' => $places,
    'events' => $events,
);

$city_ids = array();

foreach ($places as $place) {
    $city_ids[] = $place['city_id'];
}

foreach ($events as $event) {
    $city_ids[] = $event['city_id'];
}

// Убираем дубликаты
$city_ids = array_unique($city_ids);

$cities = array();

foreach ($city_ids as $city_id) {
    $sql = "SELECT
        City.id, 
        City.name_$language, 
        City.photo, 
        City.updated_at, 
        City.region_id, 
        City.country_id, 
        Region.name_$language AS region_name, 
        Region.photo AS region_photo, 
        Region.updated_at AS region_updated_at, 
        Country.isoCountryCode, 
        Country.name_$language AS country_name, 
        Country.flag_emoji, 
        Country.photo AS country_photo, 
        Country.show_regions, 
        Country.updated_at AS country_updated_at 
    FROM City 
    LEFT JOIN Region ON Region.id = City.region_id 
    LEFT JOIN Country ON Country.id = City.country_id 
    WHERE City.id = ?";

    $params = [$city_id];
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    while ($row = $cities_result->fetch_assoc()) {
        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $region_photo = $row['region_photo'];
        $region_photo_url = isset($region_photo) ? "https://www.navigay.me/" . $region_photo : null;

        $show_regions = (bool)$row['show_regions'];
        $country_photo = $row['country_photo'];
        $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

        $country = array(
            'id' => $row['country_id'],
            'name' => $row['country_name'],
            'isoCountryCode' => $row["isoCountryCode"],
            'flag_emoji' => $row['flag_emoji'],
            'photo' => $country_photo_url,
            'show_regions' => $show_regions,
            'updated_at' => $row['country_updated_at']
        );
        $region = array(
            'id' => $row['region_id'],
            'name' => $row["region_name"],
            'photo' => $region_photo_url,
            'country' => $country,
            'updated_at' => $row['region_updated_at']
        );
        $city = array(
            'id' => $row['id'],
            'name' => $row["name_$language"],
            'photo' => $photo_url,
            'updated_at' => $row['updated_at'],
            'region' => $region,
        );
        array_push($cities, $city);
    }
}
$items["cities"] = $cities;
$conn->close();
$json = ['result' => true, 'items' => $items];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
