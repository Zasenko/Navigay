<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}
$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

if ((!isset($_GET['latitude'])) || (!isset($_GET['longitude']))) {
    sendError('Latitude and Longitude is required.');
}

$latitude = floatval($_GET['latitude']);
$longitude = floatval($_GET['longitude']);

if (!isset($_GET['user_date'])) {
    sendError('Date is required.');
}

$user_date = $_GET['user_date'];

try {
    $dateTime = DateTimeImmutable::createFromFormat('Y-m-d\TH:i:s.u\Z', $user_date);
    if ($dateTime === false) {
        throw new Exception('Failed to parse date string.');
    }
    $date = $dateTime->format('Y-m-d');
    $time = $dateTime->format('H:i:s');
} catch (Exception $e) {
    sendError('Invalid date format.');
}

require_once('../dbconfig.php');

$sql = "SELECT id, name, type_id, city_id, avatar, main_photo, address, latitude, longitude, tags, timetable, updated_at 
        FROM Place 
        WHERE SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20 
        AND is_active = true";
$params = [$latitude, $longitude];
$types = "dd";
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
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}

$sql = "SELECT id, name, type_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at 
        FROM Event 
        WHERE is_active = true 
        AND SQRT(POW(latitude - ?, 2) + POW(longitude - ?, 2)) * 111.32 <= 20 
        AND (
        (finish_date IS NULL AND start_date >= ?) 
        OR (finish_date IS NOT NULL AND finish_date > ?) 
        OR (finish_date IS NOT NULL AND finish_time IS NOT NULL AND finish_date = ? AND finish_time > ?)
        )";

$params = [$latitude, $longitude, $date, $date, $date, $time];
$types = "ddssss";
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
        'city_id' => $row['city_id'],
        'updated_at' => $row['updated_at'],
    );
    array_push($events, $event);
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
            if ($event['finish_time'] !== null && $event['finish_time'] <= '10:59') {
                array_pop($eventDates);
            }
            foreach ($eventDates as $date) {
                $activeDates[$date][] = $event['id'];
            }
        }
    }

    return $activeDates;
}

$items = array();
if (empty($places) && empty($events)) {
    $sql = "SELECT 
           c.id, 
           c.name_en, 
           c.small_photo, 
           c.latitude, 
           c.longitude, 
           c.is_capital, 
           c.is_gay_paradise, 
           c.updated_at,
           SQRT(POW(c.latitude - ?, 2) + POW(c.longitude - ?, 2)) * 111.32 AS distance,
           COUNT(DISTINCT p.id) AS place_count,
           COUNT(DISTINCT e.id) AS event_count
       FROM 
           City c
       LEFT JOIN 
           Place p ON c.id = p.city_id 
               AND p.is_active = true
       LEFT JOIN 
           Event e ON c.id = e.city_id 
               AND e.is_active = true 
               AND ((e.finish_date IS NULL AND e.start_date >= ?) 
                   OR (e.finish_date IS NOT NULL AND e.finish_date > ?)
                   OR (e.finish_date IS NOT NULL AND e.finish_time IS NOT NULL AND e.finish_date = ? AND e.finish_time > ?))
       WHERE 
           c.is_active = true 
       GROUP BY 
           c.id
       HAVING 
           place_count > 0 OR event_count > 0
       ORDER BY distance ASC 
       LIMIT 3";

    $params = [$latitude, $longitude, $date, $date, $date, $time];
    $types = "ddssss";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    $cities = array();
    while ($row = $cities_result->fetch_assoc()) {
        if ($row['place_count'] == 0 && $row['event_count'] == 0) {
            continue; // Пропускаем города с нулевыми place_count и event_count
        }

        $photo = $row['small_photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $is_capital = (bool)$row['is_capital'];
        $is_gay_paradise = (bool)$row['is_gay_paradise'];

        $city = array(
            'id' => $row['id'],
            'name' => $row["name_en"],
            'small_photo' => $photo_url,
            'latitude' => $row['latitude'],
            'longitude' => $row['longitude'],
            'is_capital' => $is_capital,
            'is_gay_paradise' => $is_gay_paradise,
            'place_count' => $row['place_count'],
            'event_count' => $row['event_count'],
            'updated_at' => $row['updated_at']
        );
        array_push($cities, $city);
    }
    $items = array(
        'found_around' => false,
        'cities' => $cities,
    );
} else {
    $todayEvents = [];
    $upcomingEvents = [];

    foreach ($events as $event) {
        if ($event['start_date'] > $user_date) {
            $upcomingEvents[] = $event;
        } else {
            $todayEvents[] = $event;
        }
    }

    $sortedEvents = array(
        "today" => $todayEvents,
        "upcoming" => getUpcomingEvents($upcomingEvents, $user_date),
        "allDates" => getActiveDates($events),
    );

    $items = array(
        'found_around' => true,
        'places' => $places,
        'events' => $sortedEvents,
    );
}

$conn->close();
$json = ['result' => true, 'items' => $items];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;
?>
