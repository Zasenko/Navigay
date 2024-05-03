<?php

require_once('api/error-handler.php');
require_once('api/languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';
$userDate = isset($_GET['user_date']) ? $_GET['user_date'] : date('Y-m-d');

require_once('api/dbconfig.php');

$sql = "SELECT id, isoCountryCode, name_en, flag_emoji, photo, show_regions, updated_at FROM Country WHERE is_active = true";

$sql = "SELECT 
    c.id, 
    c.isoCountryCode, 
    c.name_en, 
    c.flag_emoji, 
    c.photo, 
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
        AND ((e.finish_date IS NULL AND e.start_date >= ?) 
            OR (e.finish_date IS NOT NULL AND e.finish_date >= ?))
WHERE 
    c.is_active = true
GROUP BY 
    c.id
ORDER BY 
    c.name_en";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    $conn->close();
    sendError('Failed to prepare SQL statement: ' . $error);
}
$stmt->bind_param("ss", $userDate, $userDate);
if (!$stmt->execute()) {
    $error = $stmt->error;
    $stmt->close();
    $conn->close();
    sendError('Execute error: ' . $error);
}
$result = $stmt->get_result();
$stmt->close();

$countriesByLetter = array();

while ($row = $result->fetch_assoc()) {

    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];

    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name' => $row["name_en"],
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $photo_url,
        'show_regions' => $show_regions,
        'place_count' => $row['place_count'], // Получаем place_count из результата запроса
        'event_count' => $row['event_count'],
        'updated_at' => $row['updated_at'],
    );

    $firstLetter = strtoupper(substr($row['name_en'], 0, 1));
    if (!isset($countriesByLetter[$firstLetter])) {
        $countriesByLetter[$firstLetter] = array();
    }
    array_push($countriesByLetter[$firstLetter], $country);
}

$all_countries = array();
foreach ($countriesByLetter as $letter => $countries) {
    $all_countries[$letter] = $countries;
}

$conn->close();
$json = array('result' => true, 'countries' => $all_countries);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
