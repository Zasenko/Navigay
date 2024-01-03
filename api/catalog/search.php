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
City.name_$language, 
City.photo, 
City.is_active, 
City.updated_at, 
City.region_id, 
City.country_id, 
Region.name_$language AS region_name, 
Region.photo AS region_photo, 
Region.is_active AS region_is_active, 
Region.updated_at AS region_updated_at, 
Country.isoCountryCode, 
Country.name_$language AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions, 
Country.is_active AS country_is_active, 
Country.updated_at AS country_updated_at 
FROM City 
LEFT JOIN Region ON Region.id = City.region_id 
LEFT JOIN Country ON Country.id = City.country_id 
WHERE 
City.name_origin LIKE ? 
OR City.name_en LIKE ? 
OR City.name_fr LIKE ? 
OR City.name_de LIKE ? 
OR City.name_ru LIKE ? 
OR City.name_it LIKE ? 
OR City.name_es LIKE ? 
AND City.is_checked = true";

$param = "%" . $search_text . "%";
$params = [$param, $param, $param, $param, $param, $param, $param];
$types = "sssssss";
$stmt = executeQuery($conn, $sql, $params, $types);
$cities_result = $stmt->get_result();
$stmt->close();
while ($row = $cities_result->fetch_assoc()) {
    //is_active
    $is_active = (bool)$row['is_active'];
    //photo
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;


    $region_is_active = (bool)$row['region_is_active'];
    $region_photo = $row['region_photo'];
    $region_photo_url = isset($region_photo) ? "https://www.navigay.me/" . $region_photo : null;

    $show_regions = (bool)$row['show_regions'];
    $country_is_active = (bool)$row['country_is_active'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

    $region = array(
        'id' => $region_id,
        'name' => $row["name_$language"],
        'photo' => $photo_url,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at']
    );
    $city = array(
        'id' => $row['id'],
        'name' => $row["name_$language"],
        'photo' => $photo_url,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
        'region' => array(
            'id' => $row['region_id'],
            'name' => $row["region_name"],
            'photo' => $region_photo_url,
            'is_active' => $region_is_active,
            'updated_at' => $row['region_updated_at']
        ),
        'country' => array(
            'id' => $row['country_id'],
            'name' => $row['country_name'],
            'isoCountryCode' => $row["isoCountryCode"],
            'flag_emoji' => $row['flag_emoji'],
            'photo' => $country_photo_url,
            'show_regions' => $show_regions,
            'is_active' => $country_is_active,
            'updated_at' => $row['country_updated_at']
        ),
    );
    array_push($cities, $city);
}

$regions = array();

$sql = "SELECT 
Region.id, 
Region.name_$language, 
Region.photo, 
Region.is_active, 
Region.updated_at, 
Region.country_id, 
Country.isoCountryCode, 
Country.name_$language AS country_name, 
Country.flag_emoji, 
Country.photo AS country_photo, 
Country.show_regions, 
Country.is_active AS country_is_active, 
Country.updated_at AS country_updated_at 
FROM Region";
$sql .= " LEFT JOIN Country ON Country.id = Region.country_id";
$sql .= " WHERE";
$sql .= " Region.name_origin LIKE ?";
$sql .= " OR Region.name_en LIKE ?";
$sql .= " OR Region.name_fr LIKE ?";
$sql .= " OR Region.name_de LIKE ?";
$sql .= " OR Region.name_ru LIKE ?";
$sql .= " OR Region.name_it LIKE ?";
$sql .= " OR Region.name_es LIKE ?";
$sql .= " AND Region.is_checked = true";

$param = "%" . $search_text . "%";
$params = [$param, $param, $param, $param, $param, $param, $param];
$types = "sssssss";
$stmt = executeQuery($conn, $sql, $params, $types);
$regions_result = $stmt->get_result();
$stmt->close();
while ($row = $regions_result->fetch_assoc()) {
    //is_active
    $is_active = (bool)$row['is_active'];
    //photo
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    //id
    $region_id = $row['id'];

    $show_regions = (bool)$row['show_regions'];
    $country_is_active = (bool)$row['country_is_active'];
    $country_photo = $row['country_photo'];
    $country_photo_url = isset($country_photo) ? "https://www.navigay.me/" . $country_photo : null;

    $region = array(
        'id' => $region_id,
        'name' => $row["name_$language"],
        'photo' => $photo_url,
        'is_active' => $is_active,
        'updated_at' => $row['updated_at'],
        'country' => array(
            'id' => $row['country_id'],
            'name' => $row['country_name'],
            'isoCountryCode' => $row["isoCountryCode"],
            'flag_emoji' => $row['flag_emoji'],
            'photo' => $country_photo_url,
            'show_regions' => $show_regions,
            'is_active' => $country_is_active,
            'updated_at' => $row['country_updated_at']
        ),
    );

    $sql = "SELECT id, name_$language, photo, is_active, updated_at FROM City WHERE region_id = ? AND is_checked = true";
    $params = [$region_id];
    $types = "i";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $cities_result = $stmt->get_result();
    $stmt->close();

    $region_cities = array();
    while ($row = $cities_result->fetch_assoc()) {
        //is_active
        $is_active = (bool)$row['is_active'];
        //photo
        $photo = $row['photo'];
        $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

        $region_city = array(
            'id' => $row['id'],
            'name' => $row["name_$language"],
            'photo' => $photo_url,
            'is_active' => $is_active,
            'updated_at' => $row['updated_at']
        );
        array_push($region_cities, $region_city);
    }
    $region += ['cities' => $region_cities];
    array_push($regions, $region);

    //TODO
    // if (count($region_cities) > 0) {
    //     array_push($regions, $region);
    // } 
}

$places = array();

$sql = "SELECT id, name, type_id, avatar, main_photo, address, latitude, longitude, tags, timetable, is_active, updated_at FROM Place WHERE";
$sql .= " name LIKE ?";
$sql .= " AND is_checked = true";

$param = "%" . $search_text . "%";
$params = [$param];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

while ($row = $result->fetch_assoc()) {
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
    array_push($places, $place);
}


$events = array();
$sql = "SELECT id, name, type_id, country_id, region_id, city_id, latitude, longitude, start_date, start_time, finish_date, finish_time, address, location, poster, poster_small, is_free, tags, place_id, is_active, updated_at FROM Event WHERE";
$sql .= " name LIKE ?";
$sql .= " AND ((finish_date IS NOT NULL AND finish_date >= CURDATE() - INTERVAL 1 DAY) OR (finish_date IS NULL AND start_date >= CURDATE() - INTERVAL 1 DAY))";
$sql .= " AND is_checked = true";

$param = "%" . $search_text . "%";
$params = [$param];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

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
