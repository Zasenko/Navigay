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
$types = "s";
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
    $logo_url = "https://navigay.me/appimages/logo/full-logo-black.svg";
    $support_email = "support@navigay.ru";

    $to = $email;
    $subject = "Password Reset";
    $message = "
    <html>
    <head>
      <title>$subject</title>
    </head>
    <body>
      <div style='text-align: center;'>
        <img src='$logo_url' alt='Navigay Logo' style='max-width: 200px;'>
        <h2>Password Reset</h2>
        <p>To reset your password, please follow the link below:</p>
        <a href='$reset_link' style='padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;'>Reset Password</a>
      </div>
      <hr>
      <div style='text-align: center;'>
        <p style='color: #888;'>If you did not request a password reset, please ignore this message.</p>
        <p style='color: #888;'>If you have any questions, feel free to contact us at <a href='mailto:$support_email' style='color: #4CAF50;'>$support_email</a>.</p>
      </div>
    </body>
    </html>
    ";
    $headers = "From: support@navigay.me\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    if (mail($to, $subject, $message, $headers)) {
        $json = ['result' => true];
        echo json_encode($json);
        exit;
    } else {
        sendError('Error sending email.');
        exit;
    }
}
