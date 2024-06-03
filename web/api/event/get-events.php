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
$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, updated_at 
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
$country_ids = array();
$region_ids = array();
$city_ids = array();

while ($row = $result->fetch_assoc()) {
    $is_free = (bool)$row['is_free'];
    $poster_small = $row['poster_small'];
    $poster_small_url = isset($poster_small) ? "https://www.navigay.me/" . $poster_small : null;
    // $poster = $row['poster'];
    // $poster_url = isset($poster) ? "https://www.navigay.me/" . $poster : null;

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
        // 'poster' => $poster_url,
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

    $country_ids = array_unique($country_ids);
    $region_ids = array_unique($region_ids);
    $city_ids = array_unique($city_ids);

    foreach ($country_ids as $country_id) {
        $sql = "SELECT id, isoCountryCode, name_en, flag_emoji, show_regions, updated_at FROM Country WHERE id = ?";
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
        $sql = "SELECT id, country_id, name_en, redirect_region_id, updated_at FROM Region WHERE id = ? AND is_active = true";
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
        WHERE City.id = ?";
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

$items = array(
        'events' => $sortedEvents,
        'cities' => $cities,
        'regions' => $regions,
        'countries' => $countries,
    );

$conn->close();
$json = ['result' => true, 'items' => $items];
echo json_encode($json);
exit;