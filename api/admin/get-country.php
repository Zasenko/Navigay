<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendError('Invalid request method.');
}

//TODO! проверка юзера на то, что он администратор

if (!isset($_GET["id"]) || !is_numeric($_GET["id"])) {
    sendError('Invalid or missing "id" parameter.');
}
$country_id = (int)$_GET["id"];

require_once('../dbconfig.php');

$sql = "SELECT id, isoCountryCode, name_origin, name_en, flag_emoji, about, photo, show_regions, is_active, is_checked FROM Country WHERE id = ?";

$params = [$country_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$country_result = $stmt->get_result();
$stmt->close();
$row = $country_result->fetch_assoc();

$show_regions = (bool)$row['show_regions'];
$is_checked = (bool)$row['is_checked'];
$is_active = (bool)$row['is_active'];

$photo = $row['photo'];
$photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;

$country = array(
    'id' => $row['id'],
    'isoCountryCode' => $row["isoCountryCode"],
    'name_origin' => $row['name_origin'],
    'name_en' => $row['name_en'],
    'flag_emoji' => $row['flag_emoji'],
    'about' => $row['about'],
    'photo' => $photo_url,
    'show_regions' => $show_regions,
    'is_active' => $is_active,
    'is_checked' => $is_checked,
);

$conn->close();
$json = ['result' => true, 'country' => $country];
echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
exit;
