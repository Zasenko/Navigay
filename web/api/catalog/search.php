<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$search_text = $_GET['text'];
if (!isset($search_text)) {
    sendError('search text is required.');
}
if (empty($search_text)) {
    sendError('Search text is required.');
}
$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

$user_date = $_GET['user_date'];
try {
    $dateTime = DateTimeImmutable::createFromFormat('Y-m-d\TH:i:s.u\Z', $user_date);
    if ($dateTime === false) {
        throw new Exception('Failed to parse date string.');
    }
    $date = $dateTime->format('Y-m-d');
    $time = $dateTime->format('H:i:s');
} catch (Exception $e) {
    sendError('Invalid date format.');
}

require_once('../dbconfig.php');

$country_ids = array();
$region_ids = array();
$city_ids = array();

$places = array();
$events = array();

$sql = "SELECT 
id, name, type_id, country_id, region_id, city_id, avatar, address, latitude, longitude, tags, timetable, updated_at 
FROM Place 
WHERE is_active = true AND name LIKE ?";

$param = "%" . $search_text . "%";
$params = [$param];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $avatar_url = isset($row['avatar']) ? "https://www.navigay.me/" . $row['avatar'] : null;

    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'avatar' => $avatar_url,
        'address' => $row['address'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    $tags = json_decode($row['tags'], true);
    if (!empty($tags)) {
        $place['tags'] = $tags;
    }
    $timetable = json_decode($row['timetable'], true);
    if (!empty($timetable)) {
        $place['timetable'] = $timetable;
    }
    array_push($places, $place);

    $city_ids[] = intval($row['city_id']);
    $region_ids[] = intval($row['region_id']);
    $country_ids[] = intval($row['country_id']);
}


$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster_small, is_free, tags, place_id, is_active, updated_at 
        FROM Event 
        WHERE is_active = true 
        AND name LIKE ? 
        AND (
        (finish_date IS NULL AND start_date >= ?) 
        OR (finish_date IS NOT NULL AND finish_date > ?) 
        OR (finish_date IS NOT NULL AND finish_time IS NOT NULL AND finish_date = ? AND finish_time > ?)
        )";
        
$param = "%" . $search_text . "%";
$params = [$param, $date, $date, $date, $time];
$types = "sssss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_free = (bool)$row['is_free'];
    $poster_small_url = isset($row['poster_small']) ? "https://www.navigay.me/" . $row['poster_small'] : null;

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
        'location' => $row['location'],
        'poster_small' => $poster_small_url,
        'is_free' => $is_free,
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
        $tags = json_decode($row['tags'], true);
    if (!empty($tags)) {
        $event['tags'] = $tags;
    }
    array_push($events, $event);

    $city_ids[] = intval($row['city_id']);
    $region_ids[] = intval($row['region_id']);
    $country_ids[] = intval($row['country_id']);
}

$cities = array();
$regions = array();
$countries = array();

$country_ids = array_unique($country_ids);
$region_ids = array_unique($region_ids);
$city_ids = array_unique($city_ids);

    foreach ($country_ids as $country_id) {
        $sql = "SELECT id, isoCountryCode, name_en, flag_emoji, show_regions, updated_at FROM Country WHERE is_active = true AND id = ?";
        $params = [$country_id];
        $types = "i";
        $stmt = executeQuery($conn, $sql, $params, $types);
        $country_result = $stmt->get_result();
        $stmt->close();

        if ($country_result->num_rows === 0) {
            $conn->close();
            sendError('Country not found.');
        }
        $row = $country_result->fetch_assoc();
        $show_regions = (bool)$row['show_regions'];
        $country = array(
            'id' => $row['id'],
            'isoCountryCode' => $row['isoCountryCode'],
            'name' => $row["name_en"],
            'flag_emoji' => $row['flag_emoji'],
            'show_regions' => $show_regions,
            'updated_at' => $row['updated_at']
        );
        array_push($countries, $country);
    }

    foreach ($region_ids as $region_id) {
        $sql = "SELECT id, country_id, name_en, redirect_region_id, updated_at FROM Region WHERE  is_active = true AND id = ?";
        $params = [$region_id];
        $types = "i";
        $stmt = executeQuery($conn, $sql, $params, $types);
        $regions_result = $stmt->get_result();
        $stmt->close();
        if ($regions_result->num_rows === 0) {
            $conn->close();
            sendError('Regions not found.');
        }
        $row = $regions_result->fetch_assoc();
        $region_id = isset($row['redirect_region_id']) ? $row['redirect_region_id'] : $row['id'];
        $region = array(
            'id' => $region_id,
            'country_id' => $row["country_id"],
            'name' => $row["name_en"],
            'updated_at' => $row['updated_at']
        );
        array_push($regions, $region);
    }

    foreach ($city_ids as $city_id) {
        $sql = "SELECT id, region_id, name_en, small_photo, latitude, longitude, is_capital, is_gay_paradise, redirect_city_id, updated_at 
        FROM City 
        WHERE is_active = true AND id = ?";
        $params = [$city_id];
        $types = "i";
        $stmt = executeQuery($conn, $sql, $params, $types);
        $cities_result = $stmt->get_result();
        $stmt->close();
        if ($cities_result->num_rows === 0) {
            $conn->close();
            sendError('Cities not found.');
        }
        $row = $cities_result->fetch_assoc();


        $city_id = isset($row['redirect_city_id']) ? $row['redirect_city_id'] : $row['id'];

        $small_photo_url = isset($row['small_photo']) ? "https://www.navigay.me/" . $row['small_photo'] : null;
        $is_capital = (bool)$row['is_capital'];
        $is_gay_paradise = (bool)$row['is_gay_paradise'];

        $city = array(
                'id' => $city_id,
                'region_id' => $row["region_id"],
                'name' => $row["name_en"],
                'small_photo' => $small_photo_url,
                'latitude' => $row['latitude'],
                'longitude' => $row['longitude'],
                'is_capital' => $is_capital,
                'is_gay_paradise' => $is_gay_paradise,
                'updated_at' => $row['updated_at'],
        );
        array_push($cities, $city);
    }

$conn->close();
$items = array(
    'places' => $places,
    'events' => $events,
    'cities' => $cities,
    'regions' => $regions,
    'countries' => $countries,
);
$json = ['result' => true, 'items' => $items];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
