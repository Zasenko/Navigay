<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}
function getUpcomingEvents($events, $user_date)
{
    $lastDayOfWeek = strtotime('+7 days', strtotime($user_date));
    $sevenDaysFromNow = getAllDatesBetween($user_date, date('Y-m-d', $lastDayOfWeek));

    $upcomingEvents = array_filter($events, function ($event) use ($sevenDaysFromNow) {
        return in_array($event['start_date'], $sevenDaysFromNow);
    });

    if (count($upcomingEvents) > 3) {
        usort($upcomingEvents, function ($a, $b) {
            return strtotime($a['start_date']) - strtotime($b['start_date']);
        });
        return $upcomingEvents;
    } else {
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
function getActiveDates($events)
{
    $activeDates = [];

    foreach ($events as $event) {
        if ($event['finish_date'] === null) {
            $activeDates[$event['start_date']][] = $event['id'];
        } elseif ($event['finish_date'] !== null && $event['finish_date'] == $event['start_date']) {
            $activeDates[$event['start_date']][] = $event['id'];
        } elseif ($event['finish_date'] !== null) {
            $eventDates = getAllDatesBetween($event['start_date'], $event['finish_date']);
            if ($event['finish_time'] === null) {
                array_pop($eventDates);
            } elseif ($event['finish_time'] !== null && $event['finish_time'] < '11:00') {
                array_pop($eventDates);
            }
            foreach ($eventDates as $date) {
                $activeDates[$date][] = $event['id'];
            }
        }
    }

    return $activeDates;
}

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$city_id = (int)$_GET["id"];

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

$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

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
        'updated_at' => $row['updated_at'],
    );
    $tags = json_decode($row['tags'], true);
    if (!empty($tags)) {
        $place['tags'] = $tags;
    }
    $timetable = json_decode($row['timetable'], true);
    if (!empty($timetable)) {
        $place['timetable'] = $timetable;
    }
    array_push($places, $place);
}
$city += ['places' => $places];

$sql = "SELECT id, name, type_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, updated_at 
        FROM Event 
        WHERE city_id = ? AND is_active = true 
        AND (
        (finish_date IS NULL AND start_date >= ?) 
        OR (finish_date IS NOT NULL AND finish_date > ?) 
        OR (finish_date IS NOT NULL AND finish_time IS NOT NULL AND finish_date = ? AND finish_time > ?)
        )";
$params = [$city_id, $date, $date, $date, $time];
$types = "issss";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$events = array();
while ($row = $result->fetch_assoc()) {

    $is_free = (bool)$row['is_free'];

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
        'is_free' => $is_free,
        'updated_at' => $row['updated_at'],
    );

    $tags = json_decode($row['tags'], true);
    if (!empty($tags)) {
        $event['tags'] = $tags;
    }
    array_push($events, $event);
}


$todayEvents = [];
$upcomingEvents = [];
$eventsCount = count($events);
    
    foreach ($events as $event) {
        if ($event['start_date'] > $date) {
            $upcomingEvents[] = $event;
        } else {
            $todayEvents[] = $event;
        }
    }

    $sortedEvents = array(
        "today" => $todayEvents,
        "upcoming" => getUpcomingEvents($upcomingEvents, $date),
        "eventsCount" => $eventsCount,
    );

    $activeDates = getActiveDates($events);
    if (!empty($activeDates)) {
        $sortedEvents['allDates'] = $activeDates;
    }


$city += ['events' => $sortedEvents];

$conn->close();
$json = array('result' => true, 'city' => $city);
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
