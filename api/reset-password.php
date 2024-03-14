<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password</title>
</head>

<body>
    <h2>Reset Password</h2>
    <?php

    // Подключение к базе данных (замените данными вашей БД)
    $host = "localhost";
    $username = "u494568686_Zasenko";
    $password = "&hEP!hEf5";
    $dbname = "u494568686_NaviGay";

    try {
        $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        echo "Database connection error: " . $e->getMessage();
        exit;
    }

    // Проверка наличия токена в URL
    if (!isset($_GET['token']) || empty($_GET['token'])) {
        echo "Invalid token.";
        exit;
    }
    $token = $_GET['token'];

    // Проверка существования токена в базе данных
    $stmt = $db->prepare("SELECT * FROM User WHERE reset_token = ?");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        echo "Invalid token.";
        exit;
    }

    // Processing password reset form
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $password = $_POST['password'];
        $confirm_password = $_POST['confirm_password'];

        // Checking if passwords match
        if ($password !== $confirm_password) {
            echo "Passwords do not match.";
            exit;
        }
        // Hashing the new password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // Updating password and resetting token in the database
        $stmt = $db->prepare("UPDATE User SET password = ?, reset_token = NULL WHERE id = ?");
        $stmt->execute([$hashed_password, $user['id']]);
        echo "Password successfully changed.";
        exit;
    }
    ?>
    <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]) . "?token=$token"; ?>">
        <label for="password">New Password:</label><br>
        <input type="password" id="password" name="password" required><br>
        <label for="confirm_password">Confirm New Password:</label><br>
        <input type="password" id="confirm_password" name="confirm_password" required><br>
        <input type="submit" value="Reset Password">
    </form>
</body>

</html>