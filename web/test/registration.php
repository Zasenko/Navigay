<?php
session_start();

if (isset($_SESSION['loggedin'])) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate and process registration
    // Implement registration logic here
}
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Registration</title>
    <!-- Include CSS -->
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <?php include('header.php'); ?>
    <div class="container">
        <h2>Registration</h2>
        <!-- Registration Form -->
        <!-- Implement the registration form here -->
    </div>
</body>

</html>