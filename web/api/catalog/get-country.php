<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$country_id = (int)$_GET["id"];

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

if (!isset($_GET['user_date'])) {
    sendError('Missing "user_date" parameter.');
}
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

$sql = "SELECT id, isoCountryCode, name_en, about, flag_emoji, photo, show_regions, updated_at FROM Country WHERE id = ?";
$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
if (!$stmt) {
    sendError('Failed to prepare SQL statement for country.');
}
$country_result = $stmt->get_result();
$stmt->close();

if ($country_result->num_rows === 0) {
    $conn->close();
    sendError('Country not found.');
}
$row = $country_result->fetch_assoc();

$show_regions = (bool)$row['show_regions'];
$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

$country = array(
    'id' => $row['id'],
    'isoCountryCode' => $row['isoCountryCode'],
    'name' => $row["name_en"],
    'flag_emoji' => $row['flag_emoji'],
    'photo' => $photo_url,
    'about' => $row['about'],
    'show_regions' => $show_regions,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name_en, photo, updated_at FROM Region WHERE country_id = ? AND is_active = true";
$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
if (!$stmt) {
    sendError('Failed to prepare SQL statement for regions.');
}
$regions_result = $stmt->get_result();
$stmt->close();

$regions = array();
while ($row = $regions_result->fetch_assoc()) {
    $region_id = $row['id'];
    $region = array(
        'id' => $region_id,
        'name' => $row["name_en"],
        'updated_at' => $row['updated_at']
    );

    $sql = "SELECT 
        c.id, 
        c.name_en, 
        c.small_photo, 
        c.latitude, 
        c.longitude, 
        c.is_capital, 
        c.is_gay_paradise, 
        c.updated_at,
        COUNT(DISTINCT p.id) AS place_count,
        COUNT(DISTINCT e.id) AS event_count
    FROM 
        City c
    LEFT JOIN 
        Place p ON c.id = p.city_id AND p.is_active = true
    LEFT JOIN 
        Event e ON c.id = e.city_id 
            AND e.is_active = true 
            AND (
                (e.finish_date IS NULL AND e.start_date >= ?) 
                OR (e.finish_date IS NOT NULL AND e.finish_date > ?) 
                OR (e.finish_date IS NOT NULL AND e.finish_time IS NOT NULL AND e.finish_date = ? AND e.finish_time > ?)
            ) 
    WHERE 
        c.region_id = ? AND c.is_active = true
    GROUP BY 
        c.id 
    HAVING 
        place_count > 0 OR event_count > 0";
    
    $params = [$date, $date, $date, $time, $region_id];
    $types = "ssssi";
    $stmt = executeQuery($conn, $sql, $params, $types);
    if (!$stmt) {
        sendError('Failed to prepare SQL statement for cities.');
    }
    $cities_result = $stmt->get_result();
    $stmt->close();

    $cities = array();
    while ($row = $cities_result->fetch_assoc()) {
        $small_photo_url = isset($row['small_photo']) ? "https://www.navigay.me/" . $row['small_photo'] : null;

        $is_capital = (bool)$row['is_capital'];
        $is_gay_paradise = (bool)$row['is_gay_paradise'];

        $city = array(
            'id' => $row['id'],
            'name' => $row["name_en"],
            'small_photo' => $small_photo_url,
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'is_capital' => $is_capital,
            'is_gay_paradise' => $is_gay_paradise,
            'updated_at' => $row['updated_at'],
            'place_count' => $row['place_count'],
            'event_count' => $row['event_count']
        );
        array_push($cities, $city);
    }
    $region += ['cities' => $cities];

    if (count($cities) > 0) {
        array_push($regions, $region);
    }
}

$country += ['regions' => $regions];

$conn->close();
$json = array('result' => true, 'country' => $country);
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
?>