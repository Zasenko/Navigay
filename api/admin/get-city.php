<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

//TODO! проверка юзера на то, что он администратор

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$city_id = (int)$_GET["id"];

require_once('../dbconfig.php');
$sql = "SELECT * FROM City WHERE id = ?";
$params = [$city_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

$row = $result->fetch_assoc();

$is_active = (bool)$row['is_active'];
    $is_checked = (bool)$row['is_checked'];
    $about_data = json_decode($row['about'], true);

    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

    $photos = json_decode($row['photos'], true);
    $library_photos = array();

    if (is_array($photos)) {
        foreach ($photos as $photoData) {
            if (isset($photoData['url']) && && isset($photoData['id'])) {
                $library_photo = array(
                    'id' => strval($photoData['id']),
                    'url' => "https://www.navigay.me/" . $photoData['url']
                );
                array_push($library_photos, $library_photo);
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
        'photo' => $photo_url,
        'photos' => $library_photos,
        'is_active' => $is_active,
        'is_checked' => $is_checked,
    );
$conn->close();
$json = ['result' => true, 'countries' => $countries, 'regions' => $regions, 'cities' => $cities, 'places' => $places];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
