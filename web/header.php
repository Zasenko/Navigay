<div class="header">
    <?php if (isset($_SESSION['loggedin'])) : ?>
        <p>Welcome, <?php echo htmlspecialchars($_SESSION['name']); ?>!</p>
        <a href="index.php">Home</a> |
        <a href="user.php">User Profile</a> |
        <a href="logout.php">Logout</a>
    <?php else : ?>
        <a href="index.php">Home</a> |
        <a href="login.php">Login</a> |
        <a href="registration.php">Registration</a>
    <?php endif; ?>
</div>