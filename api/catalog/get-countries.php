<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');



$sql = "SELECT Country.id, Country.isoCountryCode, Country.name_$language, Country.flag_emoji, Country.photo, Country.show_regions, Country.is_active, Country.updated_at,
            COUNT(DISTINCT CASE WHEN Place.is_active = true THEN Place.id END) AS places_count,
            COUNT(DISTINCT CASE WHEN Event.is_active = true 
                                AND ((Event.finish_date IS NOT NULL AND Event.finish_date >= CURDATE() - INTERVAL 1 DAY) 
                                    OR (Event.finish_date IS NULL AND Event.start_date >= CURDATE() - INTERVAL 1 DAY)) 
                              THEN Event.id END) AS events_count
        FROM Country
        LEFT JOIN Place ON Country.id = Place.country_id AND Place.is_active = true
        LEFT JOIN Event ON Country.id = Event.country_id 
        WHERE Country.is_active = true
        GROUP BY Country.id";


$stmt = $conn->prepare($sql);
if (!$stmt) {
    $conn->close();
    sendError('Failed to prepare SQL statement: ' . $error);
}
if (!$stmt->execute()) {
    $error = $stmt->error;
    $stmt->close();
    $conn->close();
    sendError('Execute error: ' . $error);
}
$result = $stmt->get_result();
$stmt->close();

$countries = array();
while ($row = $result->fetch_assoc()) {

    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];

    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name' => $row["name_$language"],
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $photo_url,
        'show_regions' => $show_regions,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
        'events_count' => (int)$row['events_count'],
        'places_count' => (int)$row['places_count'],
    );
    array_push($countries, $country);
}
$conn->close();
$json = array('result' => true, 'countries' => $countries);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
