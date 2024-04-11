<?php

//можно удалять из базы евенты сроком окончиния - год
//можно удалять из базы неактивные места сроком окончиния - 3 года


require_once('../error-handler.php');
require_once('../dbconfig.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $conn->close();
    sendError('Invalid request method.');
}
$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    $conn->close();
    sendError('Invalid or empty request data.');
}

//-------- проверка юзера
$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
if ($user_id <= 0) {
    $conn->close();
    sendError('Invalid user ID.');
}
$session_key = isset($data["session_key"]) ? $data["session_key"] : '';
if (empty($session_key)) {
    $conn->close();
    sendError('Session key is required.');
}
$hashed_session_key = hash('sha256', $session_key);

$sql = "SELECT session_key, status FROM User WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if ($result->num_rows === 0) {
    $conn->close();
    sendError('User not found.');
}
$row = $result->fetch_assoc();

$user_status = isset($row['status']) ? $row['status'] : '';
if (!($user_status === "admin" || $user_status === "moderator")) {
    $conn->close();
    sendError('Admin access only.');
}

$stored_hashed_session_key = $row['session_key'];
if (!hash_equals($hashed_session_key, $stored_hashed_session_key)) {
    $conn->close();
    sendError('Wrong session key.');
}
//-----------------

$sql = "SELECT id, isoCountryCode, name_en, is_active, is_checked FROM Country WHERE is_checked = false";
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
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row['isoCountryCode'],
        'name_en' => $row['name_en'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($countries, $country);
}

$sql = "SELECT id, name_en, is_active, is_checked FROM Region WHERE is_checked = false";
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
        'name_en' => $row['name_en'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($regions, $region);
}


//-----
$sql = "SELECT id, name_en, is_active, is_checked FROM City WHERE is_checked = false";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    $stmt->close();
    $conn->close();
    sendError('Failed to prepare statement for City.');
}
if (!$stmt->execute()) {
    $stmt->close();
    $conn->close();
    sendError('Failed to execute a prepared statement for City.');
}
$result = $stmt->get_result();
$stmt->close();
$cities = array();
while ($row = $result->fetch_assoc()) {
    $is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];

    // $photo = $row['photo'];
    // $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    // $photos = json_decode($row['photos'], true);
    // $library_photos = array();

    // if (is_array($photos)) {
    //     foreach ($photos as $photoData) {
    //         if (isset($photoData['url']) && && isset($photoData['id'])) {
    //             $library_photo = array(
    //                 'id' => strval($photoData['id']),
    //                 'url' => "https://www.navigay.me/" . $photoData['url']
    //             );
    //             array_push($library_photos, $library_photo);
    //         }
    //     }
    // }
    $city = array(
        'id' => $row['id'],
     //   'country_id' => $row["country_id"],
      //  'region_id' => $row['region_id'],
      //  'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        // 'about' => $about_data,
        // 'photo' => $photo_url,
        // 'photos' => $library_photos,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
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
    // $tags_data = json_decode($row['tags'], true);
    // $about_data = json_decode($row['about'], true);
    // $timetable = json_decode($row['timetable'], true);
    // $photos = json_decode($row['photos'], true);
    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        // 'type_id' => $row['type_id'],
        // 'country_id' => $row['country_id'],
        // 'region_id' => $row['region_id'],
        // 'city_id' => $row['city_id'],
        // 'about' => $about_data,
        // 'avatar' => $row['avatar'],
        // 'main_photo' => $row['main_photo'],
        // 'photos' => $photos,
        // 'address' => $row['address'],
        // 'latitude' => $row['latitude'],
        // 'longitude' => $row['longitude'],
        // 'www' => $row['www'],
        // 'facebook' => $row['facebook'],
        // 'instagram' => $row['instagram'],
        // 'phone' => $row['phone'],
        // 'email' => $row['email'],
        // 'tags' => $tags_data,
        // 'timetable' => $timetable,
        // 'other_info' => $row['other_info'],
        // 'owner_id' => $row['owner_id'],
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($places, $place);
}
$conn->close();
$json = ['result' => true, 'countries' => $countries, 'regions' => $regions, 'cities' => $cities, 'places' => $places];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;

// comments
// events
// users?
//






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
    
            $photo = $row['photo'];
    $main_photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    
    $country = array(
        'id' => $row['id'],
        'isoCountryCode' => $row["isoCountryCode"],
        'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'about' => $about_data,
        'flag_emoji' => $row['flag_emoji'],
        'photo' => $main_photo_url,
        'show_regions' => $show_regions,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
    array_push($countries, $country);
}

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
    
    $photo = $row['photo'];
    $main_photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    $region = array(
        'id' => $row['id'],
        'country_id' => $row["country_id"],
        'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'photo' => $main_photo_url,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
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
    $photo = $row['photo'];
    $main_photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    $photos = json_decode($row['photos'], true);
        $photo_urls = array();
    if (is_array($photos)) {
        foreach ($photos as $photoData) {
            if (isset($photoData['url']) && isset($photoData['id'])) {
                $photo_url = array(
                    'id' => $photoData['id'],
                    'url' => "https://www.navigay.me/" . $photoData['url']
                );
                array_push($photo_urls, $photo_url);
            }
        }
    }
    $city = array(
        'id' => $row['id'],
        'country_id' => $row["country_id"],
        'region_id' => $row['region_id'],
        'name_origin' => $row['name_origin'],
        'name_en' => $row['name_en'],
        'name_fr' => $row['name_fr'],
        'name_de' => $row['name_de'],
        'name_ru' => $row['name_ru'],
        'name_it' => $row['name_it'],
        'name_es' => $row['name_es'],
        'name_pt' => $row['name_pt'],
        'about' => $about_data,
        'photo' => $main_photo_url,
        'photos' => $photo_urls,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
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

    $main_photo = $row['main_photo'];
    $main_photo_url = isset($main_photo) ? "https://www.navigay.me/" . $main_photo : null;
    
    $avatar = $row['avatar'];
    $avatar_url = isset($avatar) ? "https://www.navigay.me/" . $avatar : null;
    
    
    $photos = json_decode($row['photos'], true);
        $photo_urls = array();
    if (is_array($photos)) {
        foreach ($photos as $photoData) {
            if (isset($photoData['url']) && isset($photoData['id'])) {
                $photo_url = array(
                    'id' => $photoData['id'],
                    'url' => "https://www.navigay.me/" . $photoData['url']
                );
                array_push($photo_urls, $photo_url);
            }
        }
    }
    
    $place = array(
        'id' => $row['id'],
        'name' => $row["name"],
        'type_id' => $row['type_id'],
        'country_id' => $row['country_id'],
        'region_id' => $row['region_id'],
        'city_id' => $row['city_id'],
        'about' => $about_data,
        'avatar' => $avatar_url,
        'main_photo' => $main_photo_url,
        'photos' => $photo_urls,
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
    );
    array_push($places, $place);
}
$conn->close();
$json = ['result' => true, 'countries' => $countries, 'regions' => $regions, 'cities' => $cities, 'places' => $places];
echo json_encode($json, JSON_UNESCAPED_UNICODE);
exit;

