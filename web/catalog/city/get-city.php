<?php

require_once('../../api/error-handler.php');
require_once('../../api/languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$city_id = (int)$_GET["id"];

$user_date = $_GET['user_date'];
if (!isset($user_date)) {
    sendError('Date is required.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../../api/dbconfig.php');

$sql = "SELECT id, name_en, about, small_photo, photo, photos, latitude, longitude, is_capital, is_gay_paradise, updated_at FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if ($result->num_rows === 0) {
    $conn->close();
    sendError('City not found.');
}
$row = $result->fetch_assoc();

//small_photo
$small_photo = $row['small_photo'];
$small_photo_url = isset($small_photo) ? "https://www.navigay.me/" . $small_photo : null;
//photo
$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
//photos
$photos_data = json_decode($row['photos'], true);
$photos_urls = array();

$is_capital = (bool)$row['is_capital'];
$is_gay_paradise = (bool)$row['is_gay_paradise'];

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
    'name' => $row["name_en"],
    'small_photo' => $small_photo_url,
    'photo' => $photo_url,
    'photos' => $photos_urls,
    'about' => $row['about'],
    'latitude' => $row['latitude'],
    'longitude' => $row['longitude'],
    'is_capital' => $is_capital,
    'is_gay_paradise' => $is_gay_paradise,
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, updated_at FROM Place WHERE city_id = ? AND is_active = true";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$places = array();
while ($row = $result->fetch_assoc()) {

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
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}
$groupedPlaces = [];

// Группируем места по типу
foreach ($places as $place) {
    $type = $place['type_id'];
    if (!isset($groupedPlaces[$type])) {
        $groupedPlaces[$type] = [];
    }
    $groupedPlaces[$type][] = $place;
}

$city += ['places' => $groupedPlaces];

$sql = "SELECT id, name, type_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, updated_at FROM Event WHERE city_id = ? AND is_active = true AND ((finish_date IS NULL AND start_date >= ?) OR (finish_date IS NOT NULL AND finish_date >= ?))";

$params = [$city_id, $user_date, $user_date];
$types = "iss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$events = array();
while ($row = $result->fetch_assoc()) {

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
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
}

function getUpcomingEvents($events)
{
    $lastDayOfWeek = strtotime('+7 days', strtotime(date('Y-m-d')));
    $sevenDaysFromNow = getAllDatesBetween(date('Y-m-d'), date('Y-m-d', $lastDayOfWeek));

    $upcomingEvents = array_filter($events, function ($event) use ($sevenDaysFromNow) {
        if (strtotime($event['start_date']) > strtotime(date('Y-m-d'))) {
            foreach ($sevenDaysFromNow as $day) {
                if ($event['start_date'] === $day) {
                    return true;
                }
            }
        }
        return false;
    });

    // Сортировка по дате начала события
    usort($upcomingEvents, function ($a, $b) {
        return strtotime($a['start_date']) - strtotime($b['start_date']);
    });

    // Если количество событий больше 3, возвращаем их
    if (count($upcomingEvents) > 3) {
        return $upcomingEvents;
    } else {
        // Возвращаем 4 ближайших события, если их меньше 3
        $allUpcomingEvents = array_filter($events, function ($event) {
            return strtotime($event['start_date']) > strtotime(date('Y-m-d'));
        });
        usort($allUpcomingEvents, function ($a, $b) {
            return strtotime($a['start_date']) - strtotime($b['start_date']);
        });
        return array_slice($allUpcomingEvents, 0, 4);
    }
}

function getAllDatesBetween($startDate, $finishDate)
{
    $allDates = [];
    $currentDate = strtotime($startDate);
    $finishDate = strtotime($finishDate);
    $oneDay = 24 * 60 * 60;

    while ($currentDate <= $finishDate) {
        $allDates[] = date('Y-m-d', $currentDate);
        $currentDate += $oneDay;
    }

    return $allDates;
}

$todayEvents = [];
$upcomingEvents = [];
$allDates = [];

foreach ($events as $event) {
    // Добавляем дату начала в массив всех дат
    $allDates[] = $event['start_date'];
    // Проверяем дату начала события
    if ($event['start_date'] === $user_date) {
        $todayEvents[] = $event;
    } elseif ($event['start_date'] > $user_date) {
        $upcomingEvents[] = $event;
    }
}

// Формируем итоговый массив событий
$newArray = array(
    "today" => $todayEvents,
    "upcoming" => getUpcomingEvents($upcomingEvents),
    "allDates" => array_unique($allDates) // Удаляем дубликаты дат начала
);
$city += ['events' => $newArray];

$conn->close();
$json = array('result' => true, 'city' => $city);
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
