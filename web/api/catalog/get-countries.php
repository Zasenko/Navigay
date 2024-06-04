<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

$user_date = $_GET['user_date'];
try {
    $dateTime = DateTimeImmutable::createFromFormat('Y-m-d\TH:i:s', $user_date);
    if ($dateTime === false) {
        throw new Exception('Failed to parse date string.');
    }
    $date = $dateTime->format('Y-m-d');
    $time = $dateTime->format('H:i:s');
} catch (Exception $e) {
    sendError('Invalid date format.');
}

require_once('../dbconfig.php');

$sql = "SELECT 
    c.id, 
    c.isoCountryCode, 
    c.name_en, 
    c.flag_emoji, 
    c.show_regions, 
    c.updated_at,
    COUNT(DISTINCT p.id) AS place_count,
    COUNT(DISTINCT e.id) AS event_count
FROM 
    Country c
LEFT JOIN 
    Place p ON c.id = p.country_id AND p.is_active = true
LEFT JOIN 
    Event e ON c.id = e.country_id 
        AND e.is_active = true 
        AND (
            (e.finish_date IS NULL AND e.start_date >= ?) 
            OR (e.finish_date IS NOT NULL AND e.finish_date > ?) 
            OR (e.finish_date IS NOT NULL AND e.finish_time IS NOT NULL AND e.finish_date = ? AND e.finish_time > ?)
        ) 
WHERE 
    c.is_active = true
GROUP BY 
    c.id 
HAVING 
    place_count > 0 OR event_count > 0";

$params = [$date, $date, $date, $time];
$types = "ssss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$countries = array();
while ($row = $result->fetch_assoc()) {

    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];

    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name' => $row["name_en"],
        'flag_emoji' => $row['flag_emoji'],
        'show_regions' => $show_regions,
        'place_count' => $row['place_count'],
        'event_count' => $row['event_count'],
        'updated_at' => $row['updated_at'],
    );
    array_push($countries, $country);
}
$conn->close();
$json = array('result' => true, 'countries' => $countries);
echo json_encode($json, JSON_UNESCAPED_UNICODE);
