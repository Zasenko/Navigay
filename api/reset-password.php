<?php
// Подключение к базе данных (замените данными вашей БД)
require_once('/api/dbconfig.php');

// Проверка наличия токена в URL
if (!isset($_GET['token']) || empty($_GET['token'])) {
    echo "Неверный токен.";
    exit;
}

$token = $_GET['token'];

// Проверка существования токена в базе данных
$stmt = $db->prepare("SELECT * FROM User WHERE reset_token = ?");
$stmt->execute([$token]);
$user = $stmt->fetch();

if (!$user) {
    echo "Неверный токен.";
    exit;
}

// Обработка формы сброса пароля
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $password = $_POST['password'];

    // Хэширование нового пароля
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    // Обновление пароля и сброс токена в базе данных
    $stmt = $db->prepare("UPDATE User SET password = ?, accseeeees_tocken = NULL !!!!!!!!!!!!!!!!!!!!!, reset_token = NULL WHERE id = ?");
    $stmt->execute([$hashed_password, $user['id']]);

    echo "Пароль успешно изменен.";
    exit;
}
?>

<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Сброс пароля</title>
</head>

<body>
    <h2>Сброс пароля</h2>
    <form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]) . "?token=$token"; ?>">
        <label for="password">Новый пароль:</label><br>
        <input type="password" id="password" name="password" required><br>
        <input type="submit" value="Сбросить пароль">
    </form>
</body>

</html>