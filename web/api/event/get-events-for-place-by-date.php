<?php

require_once('../error-handler.php');
//require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

//$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

if (empty($_GET["place_id"])) {
    sendError('Place ID is required.');
}
$place_id = intval($_GET["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid Place ID.');
}

try {
    $date = DateTimeImmutable::createFromFormat('Y-m-d', $_GET['date']);
    if ($date === false) {
        throw new Exception('Failed to parse date string.');
    }
    $formatted_date = $date->format('Y-m-d');
} catch (Exception $e) {
    sendError('Invalid date format.');
}

require_once('../dbconfig.php');

$sql = "SELECT id, name, type_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster_small, is_free, tags, place_id, updated_at 
        FROM Event 
        WHERE place_id = ? 
        AND is_active = true 
        AND (
            start_date = ? 
            OR 
            (start_date < ? AND finish_date IS NOT NULL AND finish_date > ?) 
            OR 
            (start_date < ? AND finish_date IS NOT NULL AND finish_time IS NOT NULL AND finish_date = ? AND finish_time >= '11:00')
            )";

$params = [$place_id, $formatted_date, $formatted_date, $formatted_date, $formatted_date, $formatted_date];
$types = "isssss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$events = []; 
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