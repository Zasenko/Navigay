<header id="header">

    <picture>
        <source media="(max-width: 799px)" srcset="https://navigay.me/images/other/icons/icon_g.svg">
        <source media="(min-width: 800px)" srcset="https://navigay.me/images/other/icons/full-logo-full-black.svg">
        <img src="https://navigay.me/images/other/icons/full-logo-full-black.svg" alt="Navigay" class="nav-logo">
    </picture>

    <div class="nav-links-container">
        <a href="https://navigay.me/test/" id="home" class="nav-link">Home</a>
        <span class="separator">•</span>
        <a href="https://navigay.me/catalog/" id="catalog" class="nav-link">Catalog</a>


        <?php if (isset($_SESSION['loggedin'])) : ?>
            <span class="separator">•</span>
            <a href="user.php" id="user" class="nav-link">User</a> |
        <?php else : ?>
            <span class="separator">•</span>
            <a href="login.php" id="login" class="nav-link">Login</a>
            <span class="separator">•</span>
            <a href="registration.php" id="registration" class="nav-link">Registration</a>
        <?php endif; ?>


    </div>

    <a href="https://navigay.me/search/" id="search" class="nav-link">
        <img src="https://navigay.me/images/other/icons/icon_search.svg" alt="Search" class="nav-icon-search">

    </a>

</header>