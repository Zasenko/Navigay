<?php
session_start();
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Home Page</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@200;300;400;600;900&display=swap');

        * {
            margin: 0;
            padding: 0;
        }

        .unselectable {
            -webkit-user-select: none;
            -webkit-touch-callout: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }

        h1 {
            font-family: 'Roboto', sans-serif;
            font-weight: 900;
            font-size: 3em;
            text-align: center;
        }

        .rainbowGradient {
            background: linear-gradient(to right, #FF0000, #0000FF, #03FF00, #FFFF00);
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        h2 {
            font-family: 'Roboto', sans-serif;
            font-weight: 400;
            font-size: 2rem;
        }

        h3 {
            font-family: 'Roboto', sans-serif;
            font-weight: 400;
            font-size: 1.5rem;
        }

        .bigText {
            font-family: 'Roboto', sans-serif;
            font-weight: 300;
            font-size: 1.5rem;
        }

        .superBigText {
            font-family: 'Roboto', sans-serif;
            font-weight: 900;
            color: black;
            font-size: 10rem;
            background: linear-gradient(to right, #FF0000, #0000FF, #03FF00, #FFFF00);
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        p {
            font-weight: 300;
            font-size: 1em;
            font-family: 'Roboto', sans-serif;
        }

        a {
            font-family: 'Roboto', sans-serif;
            font-weight: 300;
            font-size: 1em;
            color: #2897ff;
            text-decoration: underline;
        }

        a:hover {
            color: #2897ff;
            text-decoration: none;
        }

        a:visited {
            color: #2897ff;
        }

        .logoFull {
            height: 2em;
        }

        .button {
            font-family: 'Roboto', sans-serif;
            font-weight: 300;
            font-size: 1.1rem;
            background-color: #0a0a23;
            color: #fff;
            border: none;
            border-radius: 1rem;
            padding-top: 1rem;
            padding-bottom: 1rem;
            padding-left: 2rem;
            padding-right: 2rem;
        }

        .button:hover {
            background-color: #FF003D;
        }

        .button:active {
            background-color: #ffbf00;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
            border-bottom: 1px solid rgb(242, 242, 242);
        }

        .nav-overlay {
            height: 0;
            width: 100%;
            position: fixed;
            z-index: 1;
            top: 0;
            background-color: white;
            overflow-x: hidden;
            transition: 0.3s;
        }

        .nav-overlay-content {
            position: relative;
            width: 100%;
            text-align: center;
        }

        .nav-overlay a {
            padding: 8px;
            text-decoration: none;
            color: #818181;
            display: block;
            transition: 0.3s;

            font-family: 'Roboto', sans-serif;
            font-size: 2em;
            font-weight: 400;
        }

        .nav-overlay a:hover,
        .nav-overlay a:focus {
            color: #f1f1f1;
        }


        .nav-menu-btn {
            display: none;
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            outline: none;

            padding-right: 24px;
        }

        .nav-menu-close-btn {
            background: none;
            border: none;
            cursor: pointer;
            outline: none;
        }

        .nav-menu-close-btn-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding-top: 1em;
            padding-bottom: 2em;
        }

        .nav-logo {
            height: 2em;
            padding-top: 8px;
            padding-bottom: 8px;
            padding-left: 16px;
        }

        .nav-links-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1em;
            padding-right: 24px;

        }

        .nav-link {
            color: black !important;
            text-decoration: none;
            font-family: 'Roboto', sans-serif;
            font-size: 1em;
            font-weight: 400;
        }

        .nav-link:hover {
            color: black !important;
            text-decoration-line: underline;
        }

        .active.nav-link {
            color: black !important;
            font-weight: 900;
            pointer-events: none;
        }

        .nav-icon-search {
            width: 1em;
        }

        .nav-icon-search.active {
            filter: invert(34%) sepia(98%) saturate(7410%) hue-rotate(354deg) brightness(104%) contrast(101%);
        }

        .nav-menu-img {
            width: 1em;
        }

        .nav-close-img {
            width: 1.5em;
        }

        @media only screen and (max-width: 450px) {
            .nav-menu-btn {
                display: block;
            }

            .nav-links-container {
                display: none;
            }
        }

        @media screen and (min-width: 451px) {
            .nav-menu-btn {
                display: none;
            }

            .nav-links-container {
                display: flex;
            }
        }

        @media only screen and (max-width: 600px) {
            .countries-main-container {
                grid-template-columns: repeat(1, 1fr);
            }
        }

        /* Для планшета */
        @media only screen and (min-width: 601px) and (max-width: 1024px) {
            .countries-main-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Для компьютера */
        @media only screen and (min-width: 1025px) {
            .countries-main-container {
                grid-template-columns: repeat(3, 1fr);
                max-width: 1300px;
            }
        }
    </style>

</head>

<body>
    <div id="header-menu-overlay" class="nav-overlay">
        <div class="nav-overlay-content">
            <div class="nav-menu-close-btn-container">
                <button onclick="closeNav()" class="nav-menu-close-btn">
                    <img src="https://navigay.me/images/other/icons/icon_x_bold.svg" alt="Close menu" class="nav-close-img">
                </button>
            </div>
            <a href="https://navigay.me/" id="home-nav-link">Home</a>
            <a href="https://navigay.me/catalog/" id="catalog-nav-link">Catalog</a>
            <a href="https://navigay.me/search/" id="search-nav-link">Search</a>


            <?php if (isset($_SESSION['loggedin'])) : ?>
                <a href="https://navigay.me/user/" id="user-nav-link">User</a>
            <?php else : ?>
                <a href="https://navigay.me/auth/" id="login-nav-link">Login</a>
            <?php endif; ?>
        </div>
    </div>
    <header>
        <picture>
            <source media="(max-width: 699px)" srcset="https://navigay.me/images/other/icons/icon_g.svg">
            <source media="(min-width: 700px)" srcset="https://navigay.me/images/other/icons/full-logo-full-black.svg">
            <img src="https://navigay.me/images/other/icons/full-logo-full-black.svg" alt="Navigay" class="nav-logo">
        </picture>
        <div class="nav-links-container">
            <a href="https://navigay.me/" id="home-nav-link" class="nav-link">Home</a>
            <span class="separator">•</span>
            <a href="https://navigay.me/catalog/" id="catalog-nav-link" class="nav-link">Catalog</a>


            <span class="separator">•</span>

            <?php if (isset($_SESSION['loggedin'])) : ?>
                <a href="https://navigay.me/user/" id="user-nav-link" class="nav-link">User</a>
            <?php else : ?>
                <a href="https://navigay.me/auth/" id="login-nav-link" class="nav-link">Login</a>
            <?php endif; ?>

            <span class="separator">•</span>

            <a href="https://navigay.me/search/" id="search-nav-link" class="nav-link">
                <img src="https://navigay.me/images/other/icons/icon_search.svg" alt="Search" class="nav-icon-search">

            </a>
        </div>
        <button onclick="openNav()" class="nav-menu-btn">
            <img src="https://navigay.me/images/other/icons/icon_menu_bold.svg" alt="Menu" class="nav-menu-img">
        </button>
    </header>
    <script>
        function openNav() {
            document.getElementById("header-menu-overlay").style.height = "100%";
        }

        function closeNav() {
            document.getElementById("header-menu-overlay").style.height = "0";
        }
    </script>
    <script>
        document.getElementById('header').innerHTML = html;
        var currentPage = window.location.pathname.split('/').filter(Boolean).pop();
        var link;

        if (currentPage === 'search') {
            link = document.getElementById('search-nav-link');
        } else if (currentPage === 'catalog') {
            link = document.getElementById('catalog-nav-link');
        }

        if (link) {
            link.classList.add('active');
        }
    </script>

</body>

</html>