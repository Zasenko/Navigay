<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$city_id = (int)$_GET["id"];

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$sql = "SELECT id, name_$language, about, photo, photos, is_active, updated_at FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$row = $result->fetch_assoc();

//about
$about_data = json_decode($row['about'], true);
$selected_language_data = null;
$eng_language_data = null;
$any_language_data = null;
if (is_array($about_data)) {
    foreach ($about_data as $aboutItem) {
        if ($aboutItem['language'] === $language) {
            $selected_language_data = $aboutItem['about'];
            break;
        } else if ($aboutItem['language'] === 'en') {
            $eng_language_data = $aboutItem['about'];
            break;
        }
        $any_language_data = $aboutItem['about'];
    }
}
$about = $selected_language_data ?? $eng_language_data ?? $any_language_data;
//is_active
$is_active = (bool)$row['is_active'];
//photo
$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
//photos
$photos_data = json_decode($row['photos'], true);
$photos_urls = array();
foreach ($photos_data as $photoItem) {
    $url_data = $photoItem['url'];
    if (isset($url_data) && is_string($url_data)) {
        $url = "https://www.navigay.me/" . $url_data;
        array_push($photos_urls, $url);
    }
}
//id
$city_id = $row['id'];

$city = array(
    'id' => $city_id,
    'name' => $row["name_$language"],
    'photo' => $photo_url,
    'photos' => $photos_urls,
    'about' => $about,
    'is_active' => $is_active,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at FROM Place WHERE city_id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$places = array();
while ($row = $result->fetch_assoc()) {
    //is_active
    $is_active = (bool)$row['is_active'];
    //tags
    $tags = json_decode($row['tags'], true);
    //timetable
    $timetable = json_decode($row['timetable'], true);
    //avatar
    $avatar = $row['avatar'];
    $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
    //main photo
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
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}
$city += ['places' => $places];

//-------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  start_date finish_date >= now!!!!!!!!!!!!!!!!!!!!!!
$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE city_id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();


$events = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
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
        //'place_id' => $row['place_id'],
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}
$city += ['events' => $events];

$conn->close();
$json = array('result' => true, 'city' => $city);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
