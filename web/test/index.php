<?php
session_start();

class GeoPRequest
{

    public $userIp = '';
    public $city = 'unknown';
    public $state = 'unknown';
    public $country = 'unknown';
    public $countryCode = 'unknown';
    public $continent = 'unknown';
    public $continentCode = 'unknown';

    public $geoplugin_locationAccuracyRadius = 'unknown';
    public $geoplugin_latitude = 'unknown';
    public $geoplugin_longitude = 'unknown';

    public function infoByIp()
    {

        if (filter_var($this->userIp, FILTER_VALIDATE_IP) === false) {
            $this->userIp = $_SERVER["REMOTE_ADDR"];
        }

        if ($this->userIp == '127.0.0.1') {
            $this->city = $this->state = $this->country = $this->countryCode = $this->continent = $this->countryCode = 'local machine';
        }

        if (filter_var($this->userIp, FILTER_VALIDATE_IP)) {
            $ipData = json_decode(file_get_contents("http://www.geoplugin.net/json.gp?ip=" . $this->userIp));

            if (strlen(trim($ipData->geoplugin_countryCode)) == 2) {
                $this->city = $ipData->geoplugin_city;
                $this->state = $ipData->geoplugin_regionName;
                $this->country = $ipData->geoplugin_countryName;
                $this->countryCode = $ipData->geoplugin_countryCode;
                $this->continent = $ipData->geoplugin_continentName;
                $this->continentCode = $ipData->geoplugin_continentCode;

                // Добавляем получение дополнительных данных
                $this->geoplugin_locationAccuracyRadius = $ipData->geoplugin_locationAccuracyRadius;
                $this->geoplugin_latitude = $ipData->geoplugin_latitude;
                $this->geoplugin_longitude = $ipData->geoplugin_longitude;
            }
        }

        return $this;
    }

    public function getIp()
    {

        if (getenv('HTTP_CLIENT_IP')) {
            $this->userIp = getenv('HTTP_CLIENT_IP');
        } else if (getenv('HTTP_X_FORWARDED_FOR')) {
            $this->userIp = getenv('HTTP_X_FORWARDED_FOR');
        } else if (getenv('HTTP_X_FORWARDED')) {
            $this->userIp = getenv('HTTP_X_FORWARDED');
        } else if (getenv('HTTP_FORWARDED_FOR')) {
            $this->userIp = getenv('HTTP_FORWARDED_FOR');
        } else if (getenv('HTTP_FORWARDED')) {
            $this->userIp = getenv('HTTP_FORWARDED');
        } else if (getenv('REMOTE_ADDR')) {
            $this->userIp = getenv('REMOTE_ADDR');
        } else {
            $this->userIp = 'UNKNOWN';
        }

        return $this;
    }
}

$userLocationData = new GeoPRequest();
$userLocationData->getIp()->infoByIp();
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Home Page</title>
    <!-- Include CSS -->
    <link rel="stylesheet" href="../style.css">
    <style>
        main {
            width: 100%;
            justify-content: center;
        }

        h1 {
            padding-block: 0.5em;
        }

        .city-imgs-container {
            display: flex;
            justify-content: center;
            align-items: center;
            /* border-bottom: 1px solid rgb(242, 242, 242); */
        }

        .city-img {
            overflow: hidden;
        }

        @media screen and (max-width: 500px) {
            .city-img {
                width: 100%;
            }
        }

        @media screen and (min-width: 501px) {
            .city-img {
                max-width: 500px;
                /* margin: 20px; */
                border-radius: 20px;
            }
        }

        .places-main-container {
            gap: 1em;
            display: grid;
            align-items: center;
            /* Центрируем содержимое по горизонтали */
            justify-items: center;
            padding: 1em;
        }

        .sorted-places-container {
            gap: 3em;
            display: grid;
            align-items: flex-start;
            /* Центрируем содержимое по горизонтали */
            justify-items: auto;
            /* Добавляем выравнивание по центру */
            margin: auto;
        }

        .places-type-and-places-container {
            flex-direction: column;
            gap: 1em;
            display: grid;
            align-items: center;
            /* Центрируем содержимое по горизонтали */
            justify-items: auto;
            /* Добавляем выравнивание по центру */
        }

        h3 {
            padding-left: 60px;
        }

        .places-container {
            display: flex;
            flex-direction: column;
            gap: 1em;
            padding-bottom: 2em;
        }

        .place {
            align-items: center;

        }

        .place-div {
            margin-left: 60px;
            border-bottom: 1px solid rgb(242, 242, 242);
        }


        .place-container {
            display: flex;
            padding-bottom: 0.5em;
        }

        .place-info {
            display: flex;
            flex-direction: column;
            align-items: left;
        }

        .place-img {
            width: 50px;
            height: 50px;
            border: 1px solid #ccc;
            border-radius: 50%;
            margin-right: 10px;
        }

        .all-events-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            max-width: 100%;
        }

        .events-main-container {
            text-align: center;
        }

        .events-h2 {
            padding: 1em;
        }

        .events-container {
            gap: 1em;
            display: grid;
            align-items: center;
            /* Центрируем содержимое по горизонтали */
            justify-items: center;
            /* Добавляем выравнивание по центру */
        }

        @media only screen and (max-width: 600px) {
            .events-container {
                grid-template-columns: repeat(2, 1fr);
                padding: 1em;
            }

            .sorted-places-container {
                grid-template-columns: repeat(1, 1fr);
            }
        }

        @media only screen and (min-width: 601px) and (max-width: 1024px) {
            .events-container {
                grid-template-columns: repeat(2, 1fr);
                padding: 1em;
            }

            .sorted-places-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media only screen and (min-width: 1025px) {
            .events-container {
                grid-template-columns: repeat(3, 1fr);
                max-width: 1300px;
                padding: 2em;
            }

            .sorted-places-container {
                grid-template-columns: repeat(3, 1fr);
                max-width: 1300px;
            }
        }

        .event-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            border: 1px solid #ccc;
            border-radius: 16px;
            overflow: hidden;
            max-width: 300px;
        }


        .event-img {
            width: 100%;
        }

        .event-info {
            padding: 1em;
        }
    </style>
</head>

<body>
    <?php include('header.php'); ?>

    <script>
        document.getElementById('header').innerHTML = html;
        var currentPage = window.location.pathname.split('/').filter(Boolean).pop();
        if (currentPage === 'test') {
            var homeLink = document.getElementById('home');
            // Проверяем, найдена ли ссылка
            if (homeLink) {
                // Если да, добавляем ей класс 'active'
                homeLink.classList.add('active');
            }
        }
    </script>

    <main>
        <div class="container">
            <h1>Around you</h1>
            <?php if (isset($_SESSION['loggedin'])) : ?>
                <p>Welcome, <?php echo htmlspecialchars($_SESSION['name']); ?>!</p>
                <!-- Add links for user, logout -->
                <a href="user.php">User Profile</a> |
                <a href="logout.php">Logout</a>
            <?php else : ?>
                <!-- Add links for login, registration -->
                <a href="login.php">Login</a> |
                <a href="registration.php">Registration</a>
            <?php endif; ?>
        </div>

        <p>demo</p>
        <p id="demo"></p>
        <p>location</p>
        <p id="location"></p>

        <div id="isFoundAround"></div>
        <div id="events"></div>
        <div id="places"></div>

    </main>

    <!-- LOCATION -->
    <script>
        let locationFetched = false;

        function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(showPosition, handleLocationError);
                locationFetched = true;
            } else {
                fetchUserLocation()
            }
        }

        function handleLocationError(error) {
            switch (error.code) {
                case error.PERMISSION_DENIED:
                    fetchUserLocation()
                    console.log("User denied the request for Geolocation.");
                    break;
                case error.POSITION_UNAVAILABLE:
                    fetchUserLocation()
                    console.log("Location information is unavailable.");
                    break;
                case error.TIMEOUT:
                    fetchUserLocation()
                    console.log("The request to get user location timed out.");
                    break;
                case error.UNKNOWN_ERROR:
                    fetchUserLocation()
                    console.log("An unknown error occurred.");
                    break;
            }
        }

        function fetchUserLocation() {
            if ('<?php echo $userLocationData->geoplugin_latitude; ?>' !== 'unknown' && '<?php echo $userLocationData->geoplugin_longitude; ?>' !== 'unknown') {
                const latitude = parseFloat('<?php echo $userLocationData->geoplugin_latitude; ?>');
                const longitude = parseFloat('<?php echo $userLocationData->geoplugin_longitude; ?>');
                showPosition({
                    coords: {
                        latitude,
                        longitude
                    }
                });
            } else {
                console.log("User's location is not available.");
            }
        }

        function formatDate(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0'); // добавляем ведущий ноль, если месяц состоит из одной цифры
            const day = String(date.getDate()).padStart(2, '0'); // добавляем ведущий ноль, если день состоит из одной цифры
            return `${year}-${month}-${day}`;
        }


        function showPosition(position) {

            var latitude = position.coords.latitude;
            var longitude = position.coords.longitude;
            document.getElementById("demo").innerHTML = "Широта: " + latitude + "<br>Долгота: " + longitude;

            const currentDate = new Date();
            const formattedDate = formatDate(currentDate);

            fetch('get-around.php?latitude=' + latitude + '&longitude=' + longitude + '&user_date=' + formattedDate)
                .then(response => response.json())
                .then(data => {
                    if (data.result && data.items) {
                        if (data.items.found_around) {
                            const isFoundAroundDiv = document.getElementById('isFoundAround');
                            //   isFoundAroundDiv.classList.add('places-main-container');
                            const isFoundAroundHTML = `
                            <p>is found</p>
                            `;
                            isFoundAroundDiv.innerHTML = isFoundAroundHTML;
                        } else {
                            const isFoundAroundDiv = document.getElementById('isFoundAround');
                            //   isFoundAroundDiv.classList.add('places-main-container');
                            const isFoundAroundHTML = `
                            <p>not found</p>
                            `;
                            isFoundAroundDiv.innerHTML = isFoundAroundHTML;
                        }

                        // document.title = data.city.name;
                        // renderCityInfo(data.city);
                        renderEvents(data.items.events);
                        renderPlaces(data.items.places);
                        // renderAllDates(data.city.events.allDates);
                    } else {
                        console.error('Error fetching city information');
                    }
                })
                .catch(error => console.error('Error fetching location:', error));
        }

        function renderPlaces(groupedPlaces) {
            const placesDiv = document.getElementById('places');
            placesDiv.classList.add('places-main-container');

            if (Object.keys(groupedPlaces).length > 0) {
                const placesTitlerDiv = document.createElement('h2');
                placesTitlerDiv.textContent = 'Places';
                placesDiv.appendChild(placesTitlerDiv);
            }

            const sortedPlacesDiv = document.createElement('div');
            sortedPlacesDiv.classList.add('sorted-places-container');
            placesDiv.appendChild(sortedPlacesDiv);

            for (const type in groupedPlaces) {
                if (groupedPlaces.hasOwnProperty(type)) {

                    const mainDiv = document.createElement('div');
                    mainDiv.classList.add('places-type-and-places-container');


                    const placesOfType = groupedPlaces[type];
                    const typeHeader = document.createElement('h3');
                    const typeName = convertPlaceTypeToString(type);
                    typeHeader.textContent = `${typeName}`;
                    mainDiv.appendChild(typeHeader);

                    //места
                    const placesContainer = document.createElement('div');
                    placesContainer.classList.add('places-container');
                    placesOfType.forEach(place => {
                        const placeDiv = document.createElement('div');
                        placeDiv.classList.add('place');

                        const placeContaineDiv = document.createElement('div');
                        placeContaineDiv.classList.add('place-container');


                        const placeHTML = `

                        <img src="${place.avatar}" alt="${place.name} Avatar" class="place-img">

                        <div class="place-info">
                            <p><a href="place.html?id=${place.id}">${place.name}</a></p>
                            <p>${place.address}</p>
                            </div>
                        `;

                        placeContaineDiv.innerHTML = placeHTML;

                        placeDiv.appendChild(placeContaineDiv);

                        const placeLineDiv = document.createElement('div');
                        placeLineDiv.classList.add('place-div');


                        placeDiv.appendChild(placeLineDiv);
                        placesContainer.appendChild(placeDiv);
                    });

                    mainDiv.appendChild(placesContainer);
                    sortedPlacesDiv.appendChild(mainDiv);
                }
            }
        }

        function convertPlaceTypeToString(type) {
            switch (parseInt(type)) {
                case 1:
                    return "Bars";
                case 2:
                    return "Cafes";
                case 3:
                    return "Restaurants";
                case 4:
                    return "Clubs";
                case 5:
                    return "Hotels";
                case 6:
                    return "Saunas";
                case 7:
                    return "Cruise bars";
                case 8:
                    return "Beaches";
                case 9:
                    return "Shops";
                case 10:
                    return "Sport";
                case 11:
                    return "Cultur";
                case 12:
                    return "Communities";
                case 0:
                    return "Other";
                case 13:
                    return "Hostels";
                case 14:
                    return "Medicine";
                case 15:
                    return "Cruise Clubs";
                case 16:
                    return "Rights";
                default:
                    return "Other";
            }
        }

        function renderEvents(events) {

            const allEventsDiv = document.getElementById('events');
            allEventsDiv.classList.add('all-events-container');

            if (events.today.length > 0 || events.upcoming.length > 0) {
                const eventsTitlerDiv = document.createElement('h2');
                eventsTitlerDiv.textContent = 'Events';
                allEventsDiv.appendChild(eventsTitlerDiv);
            }

            if (events.today.length > 0) {
                //events main
                const eventsMainDiv = document.createElement('div');
                eventsMainDiv.classList.add('events-main-container');

                //header
                const eventHeaderDiv = document.createElement('h3');
                eventHeaderDiv.textContent = 'Today';
                eventHeaderDiv.classList.add('events-h2');
                eventsMainDiv.appendChild(eventHeaderDiv);

                // events
                const eventsDiv = document.createElement('div');
                eventsDiv.classList.add('events-container');

                if (events.today.length === 1) {
                    eventsDiv.style.gridTemplateColumns = 'repeat(1, 1fr)';
                }

                events.today.forEach(event => {
                    //info
                    const eventDiv = document.createElement('div');
                    eventDiv.classList.add('event-container');
                    eventDiv.innerHTML = `
                <img src="${event.poster_small}" alt="Poster of ${event.name}" class="event-img">
                <div class="event-info">
                <p><strong>Name:</strong> ${event.name}</p>
                <p><strong>Start Date:</strong> ${event.start_date}</p>
                </div>
                `;
                    eventsDiv.appendChild(eventDiv);
                });

                eventsMainDiv.appendChild(eventsDiv);
                allEventsDiv.appendChild(eventsMainDiv);
            }

            if (events.upcoming.length > 0) {
                //events main
                const eventsMainDiv = document.createElement('div');
                eventsMainDiv.classList.add('events-main-container');

                //header
                const eventHeaderDiv = document.createElement('h3');
                eventHeaderDiv.textContent = 'Upcoming Events';
                eventHeaderDiv.classList.add('events-h2');
                eventsMainDiv.appendChild(eventHeaderDiv);

                // events
                const eventsDiv = document.createElement('div');
                eventsDiv.classList.add('events-container');
                if (events.upcoming.length === 1) {
                    eventsDiv.style.gridTemplateColumns = 'repeat(1, 1fr)';
                }
                events.upcoming.forEach(event => {
                    //info
                    const eventDiv = document.createElement('div');
                    eventDiv.classList.add('event-container');
                    eventDiv.innerHTML = `
                    <img src="${event.poster_small}" alt="Poster of ${event.name}" class="event-img">
                <div class="event-info">
                <p><strong>${event.name}</strong></p>
                <p>Start Date: ${event.start_date}</p>
                </div>
                `;
                    eventsDiv.appendChild(eventDiv);
                });
                eventsMainDiv.appendChild(eventsDiv);
                allEventsDiv.appendChild(eventsMainDiv);
            }

        }

        document.addEventListener('DOMContentLoaded', () => {
            getLocation();
        });
    </script>
</body>

</html>