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
$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, updated_at FROM Event WHERE id IN ($placeholders) AND is_active = true";

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

while ($row = $result->fetch_assoc()) {
    $is_free = (bool)$row['is_free'];
    $poster_small = $row['poster_small'];
    $poster_small_url = isset($poster_small) ? "https://www.navigay.me/" . $poster_small : null;

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
        'updated_at' => $row['updated_at'],
    );
    $tags = json_decode($row['tags'], true);
    if (!empty($tags)) {
        $event['tags'] = $tags;
    }
    array_push($events, $event);
}

$conn->close();
$json = ['result' => true, 'events' => $events];
echo json_encode($json);
exit;