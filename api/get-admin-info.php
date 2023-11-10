<?php

//можно удалять из базы евенты сроком окончиния - год
//можно удалять из базы неактивные места сроком окончиния - 3 года


require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

//TODO! проверка юзера на то, что он администратор

require_once('../dbconfig.php');

$sql = "SELECT * FROM Country WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Country.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Country.');
}
$result = $stmt->get_result();
$stmt->close();
$countries = array();
while ($row = $result->fetch_assoc()) {
    $about_data = json_decode($row['about'], true);
    $show_regions = (bool)$row['show_regions'];
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row["isoCountryCode"],
        'name' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'about' => $about_data,
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $row['photo'],
        'show_regions' => $show_regions,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
        'updated_at' => $row['updated_at'],
    );
    array_push($countries, $country);
}

//------------
$sql = "SELECT * FROM Region WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Country.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Country.');
}
$result = $stmt->get_result();
$stmt->close();
$regions = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $region = array(
        'id' => $row['id'],
        'country_id' => $row["country_id"],
        'name' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'photo' => $row['photo'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
        'updated_at' => $row['updated_at'],
    );
    array_push($regions, $region);
}


//-----
$sql = "SELECT * FROM City WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Place.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Place.');
}
$result = $stmt->get_result();
$stmt->close();
$cities = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $about_data = json_decode($row['about'], true);
    $photos = json_decode($row['photos'], true);
    $city = array(
        'id' => $row['id'],
        'country_id' => $row["country_id"],
        'region_id' => $row['region_id'],
        'name' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'about' => $about_data,
        'photo' => $row['photo'],
        'photos' => $photos,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
        'updated_at' => $row['updated_at'],
    );
    array_push($cities, $city);
}

//-----
$sql = "SELECT * FROM Place WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for Place.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for Place.');
}
$result = $stmt->get_result();
$stmt->close();
$places = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $tags_data = json_decode($row['tags'], true);
    $about_data = json_decode($row['about'], true);
    $timetable = json_decode($row['timetable'], true);
    $photos = json_decode($row['photos'], true);
    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'country_id' => $row['country_id'],
        'region_id' => $row['region_id'],
        'city_id' => $row['city_id'],
        'about' => $about_data,
        'avatar' => $row['avatar'],
        'main_photo' => $row['main_photo'],
        'photos' => $photos,
        'address' => $row['address'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'www' => $row['www'],
        'facebook' => $row['facebook'],
        'instagram' => $row['instagram'],
        'phone' => $row['phone'],
        'email' => $row['email'],
        'tags' => $tags_data,
        'timetable' => $timetable,
        'other_info' => $row['other_info'],
        'owner_id' => $row['owner_id'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
        'updated_at' => $row['updated_at'],
    );
    array_push($places, $place);
}
$conn->close();
$json = ['result' => true, 'countries' => $countries, 'regions' => $regions, 'cities' => $cities, 'places' => $places];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
