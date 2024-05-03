<?php

require_once('api/error-handler.php');
require_once('api/languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

if (empty($_GET["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_GET["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
}
$user_date = $_GET['user_date'];
if (!isset($user_date)) {
    sendError('Date is required.');
}

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('api/dbconfig.php');

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, address, latitude, longitude, avatar, main_photo, photos, email, phone, www, facebook, instagram, about, tags, timetable, other_info, updated_at FROM Place WHERE id = ?";
$params = [$place_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$row = $result->fetch_assoc();

//todo на проверку?
$tags_data = json_decode($row['tags'], true);
$timetable = json_decode($row['timetable'], true);

$photos_data = json_decode($row['photos'], true);
$photos_urls = array();
foreach ($photos_data as $photoItem) {
    $url_data = $photoItem['url'];
    if (isset($url_data) && is_string($url_data)) {
        $url = "https://www.navigay.me/" . $url_data;
        array_push($photos_urls, $url);
    }
}
$avatar = $row['avatar'];
$avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
$main_photo = $row['main_photo'];
$main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;

$place = array(
    'id' => $row['id'],
    'name' => $row["name"],
    'type_id' => $row['type_id'],
    // 'country_id' => $row['country_id'],
    // 'region_id' => $row['region_id'],
    // 'city_id' => $row['city_id'],
    'about' => $row['about'],
    'avatar' => $avatar_url,
    'main_photo' => $main_photo_url,
    'photos' => $photos_urls,
    'address' => $row['address'],
    'latitude' => $row['latitude'],
    'longitude' => $row['longitude'],
    'www' => $row['www'],
    'facebook' => $row['facebook'],
    'instagram' => $row['instagram'],
    'phone' => $row['phone'],
    'tags' => $tags_data,
    'timetable' => $timetable,
    'other_info' => $row['other_info'],
    'updated_at' => $row['updated_at']
);

$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, updated_at FROM Event WHERE place_id = ? AND is_active = true AND ((finish_date IS NULL AND start_date >= ?) OR (finish_date IS NOT NULL AND finish_date >= ?))";
$params = [$place_id, $user_date, $user_date];
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
$place += ['events' => $newArray];

$conn->close();
$json = ['result' => true, 'place' => $place];
echo json_encode($json);
exit;
