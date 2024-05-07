<?php
session_start();

if (!isset($_SESSION['loggedin'])) {
    header('Location: login.php');
    exit;
}
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>User Profile</title>
    <!-- Include CSS -->
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <?php include('header.php'); ?>
    <div class="container">
        <h2>User Profile</h2>
        <p>Welcome, <?php echo htmlspecialchars($_SESSION['name']); ?>!</p>
        <!-- Add options to change password -->
        <a href="logout.php">Logout</a>
    </div>
</body>

</html>