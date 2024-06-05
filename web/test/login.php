<?php
session_start();
require_once('login.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postData = file_get_contents('php://input');
    $data = json_decode($postData, true);
    if (empty($data)) {
        sendError('Invalid or empty request data.');
    }

    // Call the login authentication function
    $response = authenticateUser($data, $language);

    if ($response['result']) {
        // Authentication successful
        // Set session variables
        $_SESSION['loggedin'] = true;
        $_SESSION['user'] = $response['user'];

        // Redirect to the home page or user dashboard
        header('Location: home.php');
        exit;
    } else {
        // Authentication failed
        $errorDescription = $response['errorDescription'];
        // Redirect back to the login page with error message
        header('Location: login.php?error=' . urlencode($errorDescription));
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
</head>

<body>
    <h1>Login Page</h1>
    <?php
    // Display error message if authentication failed
    if (isset($_GET['error'])) {
        $error = $_GET['error'];
        echo "<p>Error: $error</p>";
    }
    ?>

    <form action="login.php" method="post">
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br><br>
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br><br>
        <input type="submit" value="Login">
    </form>
</body>

</html>