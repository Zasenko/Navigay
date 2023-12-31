<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

require_once('../languages.php');

if (empty($_GET["event_id"])) {
    sendError('Event ID are required.');
}
$event_id = intval($_GET["event_id"]);
if ($event_id <= 0) {
    sendError('Invalid event ID.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, address, start_date, start_time, finish_date, finish_time, poster, poster_small, location, about, is_free, tickets, fee, phone, www, facebook, instagram, tags, place_id, is_active, updated_at FROM Event WHERE id = ?";
$params = [$event_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$row = $result->fetch_assoc();

$is_active = (bool)$row['is_active'];
$is_free = (bool)$row['is_free'];

//todo на проверку
$tags_data = json_decode($row['tags'], true);

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
    'location' => $row['location'],

    'poster' => $poster_url,
    'poster_small' => $poster_small_url,
    'place_id' => $row['place_id'],
    // country_id, region_id, city_id,
    'about' => $about,
    'tickets' => $row['tickets'],
    'fee' => $row['fee'],
    'www' => $row['www'],
    'facebook' => $row['facebook'],
    'instagram' => $row['instagram'],
    'phone' => $row['phone'],
    'tags' => $tags_data,
    'is_free' => $is_free,
    'is_active' => $is_active,
    'updated_at' => $row['updated_at']
);
$place_id = $row['place_id'];
if (isset($place_id)) {
    $sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at FROM Place WHERE id = ?";
    $params = [$place_id]; /////////
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $result = $stmt->get_result();
    $stmt->close();
    $place = array();
    $row = $result->fetch_assoc();
    $is_active = (bool)$row['is_active'];
    $tags = json_decode($row['tags'], true);
    $timetable = json_decode($row['timetable'], true);
    $avatar = $row['avatar'];
    $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
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
    $event += ['place' => $place];
}
$conn->close();
$json = ['result' => true, 'event' => $event];
echo json_encode($json, JSON_NUMERIC_CHECK);
exit;
