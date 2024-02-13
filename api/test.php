<?php

function sendError($errorMessage)
{
    $json = ['result' => false, 'error' => ['show' => false, 'message' => $errorMessage]];
    echo json_encode($json);
    exit;
}

// отправляет ошибку пользователю -  не закрывая $stmt и $conn
function sendUserError($errorMessage)
{
    $json = ['result' => false, 'error' => ['show' => true, 'message' => $errorMessage]];
    echo json_encode($json, JSON_UNESCAPED_UNICODE);
    exit;
}

// возвращает $stmt / в случае ошибки закрывает $stmt и $conn
function executeQuery($conn, $sql, $params, $types)
{
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        $error = $conn->error;
        $conn->close();
        sendError('Failed to prepare SQL statement: ' . $error);
    }
    $stmt->bind_param($types, ...$params);
    if (!$stmt->execute()) {
        $error = $stmt->error;
        $stmt->close();
        $conn->close();
        sendError('Execute error: ' . $error);
    }
    return $stmt;
}

// возвращает true и закрывает $stmt / в случае false закрывает $stmt и $conn
function checkInsertResult($stmt, $conn, $errorMessage)
{
    if ($stmt->affected_rows === 0) {
        $error = $stmt->error;
        $stmt->close();
        $conn->close();
        sendError($error);
    } else {
        $stmt->close();
        return true;
    }
}

// возвращает последний id / в случае null закрывает $conn
function getLastInsertId($conn)
{
    $lastInsertId = $conn->insert_id;

    if ($lastInsertId !== null) {
        return $lastInsertId;
    } else {
        $conn->close();
        sendError('Failed to retrieve the last insert ID.');
    }
}

$languages = array("en", "es", "fr", "ru", "it", "de", "pt");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);
if (empty($data)) {
    sendError('Invalid or empty request data.');
}

$user_language = isset($data["language"]) && in_array($data["language"], $languages) ? $data["language"] : 'en';

$user_email = isset($data["email"]) ? filter_var($data["email"], FILTER_SANITIZE_EMAIL) : "";
$user_email = filter_var($user_email, FILTER_VALIDATE_EMAIL);
if (!$user_email) {
    $errorDescription = getAuthErrorMessage(1, $user_language);
    sendUserError($errorDescription);
}

$user_password = isset($data["password"]) ? $data["password"] : "";
if (strlen($user_password) < 8) {
    $errorDescription = getAuthErrorMessage(2, $user_language);
    sendUserError($errorDescription);
}
if (!preg_match("/[a-zA-Z]/", $user_password)) {
    $errorDescription = getAuthErrorMessage(3, $user_language);
    sendUserError($errorDescription);
}
if (!preg_match("/[0-9]/", $user_password)) {
    $errorDescription = getAuthErrorMessage(4, $user_language);
    sendUserError($errorDescription);
}

$db_host = "localhost";
$db_username = "u49456438686_Zasenko";
$db_password = "&hE4553P!hEf5";
$db_dbname = "u4945645328686_NaviGay";

$conn = mysqli_connect($db_host, $db_username, $db_password, $db_dbname);
if (mysqli_connect_errno()) {
    $error = array('show' => false, 'message' => 'Failed to connect DataBase: ' . $conn->connect_error);
    $json = array('result' => false, 'error' => $error);
    echo json_encode($json, JSON_NUMERIC_CHECK);
    exit;
}
$sql = "SELECT * FROM User WHERE email = ? LIMIT 1";
$params = [$user_email];
$types = "s";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();

if (!($result->num_rows > 0)) {
    $conn->close();
    $errorDescription = getAuthErrorMessage(5, $user_language);
    sendUserError($errorDescription);
}

$row = $result->fetch_assoc();
$user_id = $row['id'];

if (!password_verify($user_password, $row['password'])) {
    $conn->close();
    $errorDescription = getAuthErrorMessage(7, $user_language);
    sendUserError($errorDescription);
}

$session_key = bin2hex(random_bytes(16));

// $sql = "UPDATE User SET last_time_online = CURRENT_TIMESTAMP() WHERE id = ?";
$sql = "UPDATE User SET session_key = $session_key WHERE id = ?";
$params = [$user_id];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);

if (checkInsertResult($stmt, $conn, 'Failed to update user with ID ' . $user_id)) {
    $photo = $row['photo'];
    $photo_url = isset($photo) ? "https://www.navigay.me/" . $photo : null;
    $user = array(
        'id' => $user_id,
        'name' => $row['name'],
        'email' => $row['email'],
        'status' => $row['status'],
        'bio' => $row["bio"],
        'photo' => $photo_url,
        'updated_at' => $row['updated_at'],
        'session_key' => $session_key,
    );

    $conn->close();
    $json = array('result' => true, 'user' => $user);
    echo json_encode($json, JSON_NUMERIC_CHECK | JSON_UNESCAPED_UNICODE);
    exit;
}
