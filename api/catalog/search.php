<?php

require_once('../error-handler.php');
require_once('../languages.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

$search_text = $_GET['text'];
if (!isset($search_text)) {
    sendError('search text is required.');
}
if (empty($search_text)) {
    sendError('Search text is required.');
}
$language = isset($_GET['language']) && in_array($_GET['language'], $languages) ? $_GET['language'] : 'en';

require_once('../dbconfig.php');

$cities = array();

$sql = "SELECT
City.id, 
City.name_en, 
City.small_photo
City.photo, 
City.updated_at, 
City.region_id, 
City.country_id, 
Region.name_en AS region_name, 
Region.photo AS region_photo, 
Region.updated_at AS region_updated_at, 
Country.isoCountryCode, 
Country.name_en AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions,
Country.updated_at AS country_updated_at 
FROM City 
LEFT JOIN Region ON Region.id = City.region_id 
LEFT JOIN Country ON Country.id = City.country_id 
WHERE (City.name_origin LIKE ? OR City.name_en LIKE ?) 
AND City.is_active = true";
$param = "%" . $search_text . "%";
$params = [$param, $param];
$types = "ss";
$stmt = executeQuery($conn, $sql, $params, $types);
$cities_result = $stmt->get_result();
$stmt->close();
while ($row = $cities_result->fetch_assoc()) {
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $small_photo = $row['small_photo'];
    $small_photo_url = isset($small_photo) ? "https://www.navigay.me/" . $small_photo : null;

    $region_photo = $row['region_photo'];
    $region_photo_url = isset($region_photo) ? "https://www.navigay.me/" . $region_photo : null;

    $show_regions = (bool)$row['show_regions'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

    $country = array(
        'id' => $row['country_id'],
        'name' => $row['country_name'],
        'isoCountryCode' => $row["isoCountryCode"],
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $country_photo_url,
        'show_regions' => $show_regions,
        'updated_at' => $row['country_updated_at']
    );
    $region = array(
        'id' => $row['region_id'],
        'name' => $row["region_name"],
        'photo' => $region_photo_url,
        'updated_at' => $row['region_updated_at'],
        'country' => $country,
    );
    $city = array(
        'id' => $row['id'],
        'name' => $row["name_en"],
        'small_photo' => $small_photo_url,
        'photo' => $photo_url,
        'updated_at' => $row['updated_at'],
        'region' => $region,
    );
    array_push($cities, $city);
}

$regions = array();

$sql = "SELECT 
Region.id, 
Region.name_en, 
Region.photo, 
Region.updated_at, 
Region.country_id, 
Country.isoCountryCode, 
Country.name_en AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions, 
Country.updated_at AS country_updated_at 
FROM Region 
LEFT JOIN Country ON Country.id = Region.country_id 
WHERE (Region.name_origin LIKE ? OR Region.name_en LIKE ?) 
AND Region.is_active = true";

$param = "%" . $search_text . "%";
$params = [$param, $param];
$types = "ss";
$stmt = executeQuery($conn, $sql, $params, $types);
$regions_result = $stmt->get_result();
$stmt->close();
while ($row = $regions_result->fetch_assoc()) {

    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $region_id = $row['id'];

    $show_regions = (bool)$row['show_regions'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

    $country = array(
        'id' => $row['country_id'],
        'name' => $row['country_name'],
        'isoCountryCode' => $row["isoCountryCode"],
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $country_photo_url,
        'show_regions' => $show_regions,
        'updated_at' => $row['country_updated_at']
    );

    $region = array(
        'id' => $region_id,
        'name' => $row["name_en"],
        'photo' => $photo_url,
        'updated_at' => $row['updated_at'],
        'country' => $country,
    );

    $sql = "SELECT id, name_en, small_photo, photo, updated_at FROM City WHERE region_id = ? AND is_active = true";
    $params = [$region_id];
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    $region_cities = array();
    while ($row = $cities_result->fetch_assoc()) {
        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $small_photo = $row['small_photo'];
        $small_photo_url = isset($small_photo) ? "https://www.navigay.me/" . $small_photo : null;

        $region_city = array(
            'id' => $row['id'],
            'name' => $row["name_en"],
            'small_photo' => $small_photo_url,
            'photo' => $photo_url,
            'updated_at' => $row['updated_at'],
        );
    }
    $region += ['cities' => $region_cities];
    if (count($region_cities) > 0) {
        array_push($regions, $region);
    }
}

$places = array();

$sql = "SELECT 
Place.id, 
Place.name, 
Place.type_id, 
Place.country_id,
Place.region_id,
Place.city_id,
Place.avatar, 
Place.main_photo, 
Place.address, 
Place.latitude, 
Place.longitude, 
Place.tags, 
Place.timetable, 
Place.updated_at, 
Country.isoCountryCode, 
Country.name_en AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions, 
Country.updated_at AS country_updated_at, 
Region.name_en AS region_name, 
Region.photo AS region_photo, 
Region.updated_at AS region_updated_at, 
City.name_en AS city_name, 
City.photo AS city_photo, 
City.small_photo AS city_small_photo, 
City.updated_at AS city_updated_at 
FROM Place
LEFT JOIN Country ON Country.id = Place.country_id
LEFT JOIN Region ON Region.id = Place.region_id
LEFT JOIN City ON City.id = Place.city_id
WHERE Place.name LIKE ?
AND Place.is_active = true";

$param = "%" . $search_text . "%";
$params = [$param];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $tags = json_decode($row['tags'], true);
    $timetable = json_decode($row['timetable'], true);

    $avatar = $row['avatar'];
    $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;

    $main_photo = $row['main_photo'];
    $main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;

    $city_photo = $row['city_photo'];
    $city_photo_url = isset($city_photo) ? "https://www.navigay.me/" . $city_photo : null;

    $city_small_photo = $row['city_small_photo'];
    $city_small_photo_url = isset($city_small_photo) ? "https://www.navigay.me/" . $city_small_photo : null;

    $region_photo = $row['region_photo'];
    $region_photo_url = isset($region_photo) ? "https://www.navigay.me/" . $region_photo : null;

    $show_regions = (bool)$row['show_regions'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

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
        'city' => array(
            'id' => $row['city_id'],
            'name' => $row["city_name"],
            'small_photo' => $city_small_photo_url,
            'photo' => $city_photo_url,
            'updated_at' => $row['city_updated_at'],
            'region' => array(
                'id' => $row['region_id'],
                'name' => $row["region_name"],
                'photo' => $region_photo_url,
                'updated_at' => $row['region_updated_at'],
                'country' => array(
                    'id' => $row['country_id'],
                    'name' => $row['country_name'],
                    'isoCountryCode' => $row["isoCountryCode"],
                    'flag_emoji' => $row['flag_emoji'],
                    'photo' => $country_photo_url,
                    'show_regions' => $show_regions,
                    'updated_at' => $row['country_updated_at']
                ),
            ),
        ),
    );
    array_push($places, $place);
}

$events = array();
$sql = "SELECT 
Event.id, 
Event.name, 
Event.type_id, 
Event.country_id, 
Event.region_id, 
Event.city_id, 
Event.latitude, 
Event.longitude, 
Event.start_date, 
Event.start_time, 
Event.finish_date, 
Event.finish_time, 
Event.address, 
Event.location, 
Event.poster, 
Event.poster_small, 
Event.is_free, 
Event.tags, 
Event.updated_at, 
Country.isoCountryCode, 
Country.name_en AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions, 
Country.updated_at AS country_updated_at, 
Region.name_en AS region_name, 
Region.photo AS region_photo, 
Region.updated_at AS region_updated_at, 
City.name_en AS city_name, 
City.small_photo AS city_small_photo, 
City.photo AS city_photo, 
City.updated_at AS city_updated_at 
FROM Event";
$sql .= " LEFT JOIN Country ON Country.id = Event.country_id";
$sql .= " LEFT JOIN Region ON Region.id = Event.region_id";
$sql .= " LEFT JOIN City ON City.id = Event.city_id";
$sql .= " WHERE";
$sql .= " Event.name LIKE ?";
$sql .= " AND ((Event.finish_date IS NOT NULL AND Event.finish_date >= CURDATE() - INTERVAL 1 DAY) OR (Event.finish_date IS NULL AND Event.start_date >= CURDATE() - INTERVAL 1 DAY))";
$sql .= " AND Event.is_active = true";

$param = "%" . $search_text . "%";
$params = [$param];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
    $is_free = (bool)$row['is_free'];
    $tags = json_decode($row['tags'], true);
    $poster_small = $row['poster_small'];
    $poster_small_url = isset($poster_small) ? "https://www.navigay.me/" . $poster_small : null;
    $poster = $row['poster'];
    $poster_url = isset($poster) ? "https://www.navigay.me/" . $poster : null;

    $city_small_photo = $row['city_small_photo'];
    $city_small_photo_url = isset($city_small_photo) ? "https://www.navigay.me/" . $city_small_photo : null;

    $city_photo = $row['city_photo'];
    $city_photo_url = isset($city_photo) ? "https://www.navigay.me/" . $city_photo : null;

    $region_photo = $row['region_photo'];
    $region_photo_url = isset($region_photo) ? "https://www.navigay.me/" . $region_photo : null;

    $show_regions = (bool)$row['show_regions'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

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
        'city' => array(
            'id' => $row['city_id'],
            'name' => $row["city_name"],
            'small_photo' => $city_small_photo_url,
            'photo' => $city_photo_url,
            'updated_at' => $row['city_updated_at'],
            'region' => array(
                'id' => $row['region_id'],
                'name' => $row["region_name"],
                'photo' => $region_photo_url,
                'updated_at' => $row['region_updated_at'],
                'country' => array(
                    'id' => $row['country_id'],
                    'name' => $row['country_name'],
                    'isoCountryCode' => $row["isoCountryCode"],
                    'flag_emoji' => $row['flag_emoji'],
                    'photo' => $country_photo_url,
                    'show_regions' => $show_regions,
                    'updated_at' => $row['country_updated_at']
                ),
            ),
        ),
    );
    array_push($events, $event);
}

$conn->close();
$items = array(
    'cities' => $cities,
    'regions' => $regions,
    'places' => $places,
    'events' => $events,
);
$json = ['result' => true, 'items' => $items];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
