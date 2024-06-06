<?php

require_once('../error-handler.php');
//require_once('../languages.php');

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
            $activeDates[] = $event['start_date'];
        } elseif ($event['finish_date'] !== null && $event['finish_date'] == $event['start_date']) {
            $activeDates[] = $event['start_date'];
        } elseif ($event['finish_date'] !== null) {
            $eventDates = getAllDatesBetween($event['start_date'], $event['finish_date']);
            if ($event['finish_time'] === null || ($event['finish_time'] !== null && $event['finish_time'] < '11:00')) {
                array_pop($eventDates);
            }
            foreach ($eventDates as $date) {
                $activeDates[] = $date;
            }
        }
    }
    // Remove duplicates and sort the dates
    $activeDates = array_unique($activeDates);
    sort($activeDates);
    return $activeDates;
}

if (empty($_GET["place_id"])) {
    sendError('Place ID are required.');
}
$place_id = intval($_GET["place_id"]);
if ($place_id <= 0) {
    sendError('Invalid place ID.');
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

//$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

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
$avatar_url = isset($row['avatar']) ? "https://www.navigay.me/" . $row['avatar'] : null;
$main_photo_url = isset($row['main_photo']) ? "https://www.navigay.me/" . $row['main_photo'] : null;

$place = array(
    'id' => $row['id'],
    'name' => $row["name"],
    'type_id' => $row['type_id'],
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

$tags = json_decode($row['tags'], true);
if (!empty($tags)) {
    $place['tags'] = $tags;
}
$timetable = json_decode($row['timetable'], true);
if (!empty($timetable)) {
    $place['timetable'] = $timetable;
}

$sql = "SELECT id, name, type_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, updated_at 
FROM Event 
WHERE place_id = ? AND is_active = true 
AND (
    (finish_date IS NULL AND start_date >= ?) 
    OR (finish_date IS NOT NULL AND finish_date > ?) 
    OR (finish_date IS NOT NULL AND finish_time IS NOT NULL AND finish_date = ? AND finish_time > ?))";

$params = [$place_id, $date, $date, $date, $time];
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
       $place['tags'] = $tags;
    }
    array_push($events, $event);
}

$eventsCount = count($events);

$todayEvents = [];
$upcomingEvents = [];

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
        $sortedEvents['calendarDates'] = $activeDates;
}

$place += ['events' => $sortedEvents];

$conn->close();
$json = ['result' => true, 'place' => $place];
echo json_encode($json);
exit;
