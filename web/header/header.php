<div id="header-menu-overlay" class="nav-overlay">
    <div class="nav-overlay-content">
        <div class="nav-menu-close-btn-container">
            <button onclick="closeNav()" class="nav-menu-close-btn">
                <img src="https://navigay.me/images/other/icons/icon_x_bold.svg" alt="Close menu" class="nav-close-img">
            </button>
        </div>
        <a href="https://navigay.me/" id="home">Home</a>
        <a href="https://navigay.me/catalog/" id="catalog">Catalog</a>
        <a href="https://navigay.me/search/" id="search">Search</a>
        <a href="https://navigay.me/auth/" id="login">Login</a>
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
        <a href="https://navigay.me/auth/" id="login-nav-link" class="nav-link">Login</a>
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
<main>
</main>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        var currentPage = window.location.pathname;

        var homeLink = document.getElementById('home-nav-link');
        var catalogLink = document.getElementById('catalog-nav-link');
        var searchLink = document.getElementById('search-nav-link');

        if (currentPage === "/") {
            homeLink.classList.add("disabled");
            homeLink.setAttribute("disabled", "true");
        } else if (currentPage.endsWith('/search/')) {
            searchLink.classList.add("disabled");
            searchLink.setAttribute("disabled", "true");
        } else if (currentPage.endsWith('/catalog/')) {
            catalogLink.classList.add("disabled");
            catalogLink.setAttribute("disabled", "true");
        }
    });
</script>