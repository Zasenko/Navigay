<?php

require_once('../error-handler.php');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendError('Invalid request method.');
}

$postData = file_get_contents('php://input');
$data = json_decode($postData, true);

if (empty($data)) {
    sendError('Empty Data.');
}
$email = $data['email'];
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    sendError('Invalid or empty request data.');
}

require_once('../dbconfig.php');

$sql = "SELECT * FROM User WHERE email = ?";
$params = [$email];
$types = "i";
$stmt = executeQuery($conn, $sql, $params, $types);
$result = $stmt->get_result();
$stmt->close();
if ($result->num_rows === 0) {
    $conn->close();
    $errorMessage = 'Пользователь с таким email не найден.';
    sendUserError($errorMessage);
}

$token = bin2hex(random_bytes(32)); // Генерация случайного токена

$sql = "UPDATE User SET reset_token = ? WHERE email = ?";
$params = [$token, $email];
$types = "ss";
$stmt = executeQuery($conn, $sql, $params, $types);
if (checkInsertResult($stmt, $conn, 'Failed to update token in User table.')) {

    $conn->close();

    $reset_link = "http://navigay.me/reset_password.php?token=$token";
    $to = $email;
    $subject = "Восстановление пароля";
    $message = "Для восстановления пароля перейдите по следующей ссылке: $reset_link";
    $headers = "From: support@navigay.me";

    if (mail($to, $subject, $message, $headers)) {
        $json = ['result' => true];
        echo json_encode($json);
        exit;
    } else {
        sendError('Ошибка отправки email.');
        exit;
    }
}
