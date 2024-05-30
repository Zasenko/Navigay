<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

if (!isset($_GET['event_ids'])) {
    sendError('Event IDs are required.');
}

$event_ids = $_GET['event_ids'];
$event_ids_array = explode(',', $event_ids);

if (empty($event_ids_array)) {
    sendError('No valid Event IDs provided.');
}

// Преобразование строковых значений в целые числа
$event_ids_array = array_map('intval', $event_ids_array);

// Проверка, что все элементы массива являются целыми числами и больше нуля
$event_ids_array = array_filter($event_ids_array, function($id) {
    return $id > 0;
});

if (empty($event_ids_array)) {
    sendError('No valid Event IDs provided.');
}

require_once('../dbconfig.php');

$placeholders = implode(',', array_fill(0, count($event_ids_array), '?'));

// Формируем SQL-запрос
$sql = "SELECT id, name, type_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, updated_at 
        FROM Event 
        WHERE id IN ($placeholders) AND is_active = true";

$stmt = $conn->prepare($sql);
if ($stmt === false) {
    sendError('Failed to prepare statement.');
}

// Привязываем параметры к запросу
$types = str_repeat('i', count($event_ids_array)); // все параметры целочисленные
$stmt->bind_param($types, ...$event_ids_array);

if (!$stmt->execute()) {
    sendError('Failed to execute statement.');
}

$result = $stmt->get_result();
$stmt->close();

$events = array();
$city_ids = array();

while ($row = $result->fetch_assoc()) {
    $city_ids[] = $row['city_id']; // Исправлено на $row['city_id']

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
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}

$city_ids = array_unique($city_ids);

if (!empty($city_ids)) {
    $city_placeholders = implode(',', array_fill(0, count($city_ids), '?'));

    // Формируем SQL-запрос для городов
    $sql = "SELECT
            City.id, 
            City.name_en, 
            City.small_photo,
            City.photo, 
            City.latitude, 
            City.longitude, 
            City.is_capital, 
            City.is_gay_paradise, 
            City.updated_at, 
            City.region_id, 
            City.country_id, 
            Region.name_en AS region_name, 
            Region.photo AS region_photo, 
            Region.updated_at AS region_updated_at, 
            Country.isoCountryCode, 
            Country.name_en AS country_name, 
            Country.flag_emoji, 
            Country.photo AS country_photo, 
            Country.show_regions, 
            Country.updated_at AS country_updated_at 
        FROM City 
        LEFT JOIN Region ON Region.id = City.region_id 
        LEFT JOIN Country ON Country.id = City.country_id 
        WHERE City.id IN ($city_placeholders)";

    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        sendError('Failed to prepare statement for cities.');
    }

    // Привязываем параметры к запросу
    $types = str_repeat('i', count($city_ids)); // все параметры целочисленные
    $stmt->bind_param($types, ...$city_ids);

    if (!$stmt->execute()) {
        sendError('Failed to execute statement for cities.');
    }

    $cities_result = $stmt->get_result();
    $stmt->close();

    $cities = array();

    while ($row = $cities_result->fetch_assoc()) {
        $small_photo = $row['small_photo'];
        $small_photo_url = isset($small_photo) ? "https://www.navigay.me/" . $small_photo : null;

        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $is_capital = (bool)$row['is_capital'];
        $is_gay_paradise = (bool)$row['is_gay_paradise'];

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
            'small_photo' => $small_photo_url,
            'photo' => $photo_url,
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'is_capital' => $is_capital,
            'is_gay_paradise' => $is_gay_paradise,
            'updated_at' => $row['updated_at'],
            'region' => $region,
        );
        array_push($cities, $city);
    }
} else {
    error_log("No cities found.");
}

$conn->close();
$json = ['result' => true, 'events' => $events, 'cities' => $cities];
echo json_encode($json);
exit;