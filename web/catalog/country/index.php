<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    <meta name="description" content="">
    <meta name="author" content="Dmitry Zasenko">
    <?php include('../header/head-icons.php'); ?>
    <link rel="stylesheet" type="text/css" href="../../css/header.css">
    <link rel="stylesheet" href="../../css/style.css">
    <style>
        main {
            width: 100%;
            justify-content: center;
            max-width: 1300px;
            margin: auto;
            /* Добавляем свойство для центрирования */
        }

        .country-container {}

        h1 {
            padding-block: 0.5em;

        }

        .country-imgs-container {
            display: flex;
            justify-content: center;
            align-items: center;
            /* border-bottom: 1px solid rgb(242, 242, 242); */
        }

        .country-img {
            border-radius: 20px;
            overflow: hidden;
        }

        @media screen and (max-width: 600px) {
            .country-img {
                width: 100%;
            }
        }

        @media screen and (min-width: 601px) {
            .country-img {
                max-width: 500px;
                margin: 20px;
            }
        }

        .regions-container {
            gap: 2em;
            padding: 2em;
            display: grid;
        }


        @media only screen and (max-width: 600px) {
            .regions-container {
                grid-template-columns: repeat(1, 1fr);
            }
        }

        @media only screen and (min-width: 601px) and (max-width: 1024px) {
            .regions-container {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media only screen and (min-width: 1025px) {
            .regions-container {
                grid-template-columns: repeat(3, 1fr);
                max-width: 1300px;
            }
        }

        .region-container {
            gap: 1em;
            padding-bottom: 2em;
            grid-column-gap: 1em;
        }

        .region-name {
            margin-left: 120px;
            font-size: 1.2em;
            font-weight: 600;

        }

        .cities-container {
            gap: 1em;
            padding-bottom: 2em;
            grid-column-gap: 1em;
        }

        .city-container {
            display: flex;
            align-items: center;
            width: 100%;
            padding-block: 0.5em;
        }

        .city-img {
            border-radius: 16px;
            overflow: hidden;
            width: 100px;
            margin-right: 20px;
        }

        .city-info {
            padding-bottom: 1em;
            border-bottom: 1px solid rgb(242, 242, 242);
        }

        .city-info a {
            color: #2897ff;
            text-decoration: underline;
            font-family: 'Roboto', sans-serif;
            font-size: 1.7em;
            font-weight: 400;
        }

        .city-info a:hover {
            color: black;
            text-decoration-line: underline;
        }

        h2 {
            font-weight: 600;
            font-size: 1.5em;
        }
    </style>
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.5.1/leaflet.css">
    <script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js'></script>
    <script type='text/javascript' src='https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.5.1/leaflet.js'></script>
</head>

<body>
    <?php include('../../header/header.php'); ?>
    <main>
        <div id="country">
        </div>
    </main>

    <script>
        async function fetchCountry(id) {
            try {
                const url = `get-country.php?id=${id}`;

                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error('Failed to fetch countries: ' + response.status);
                }
                const data = await response.json();


                if (data.result && data.country) {
                    document.title = data.country.name;
                    renderCountriesInfo(data.country);
                } else {
                    throw new Error('Unexpected response format');
                }
            } catch (error) {
                console.error('Error fetching countries information:', error);
            }
        }

        function getPins(cities) {

            const latitudes = cities.map(city => city.latitude);
            const longitudes = cities.map(city => city.longitude);

            // Находим среднее значение широты и долготы
            const avgLat = latitudes.reduce((sum, lat) => sum + lat, 0) / latitudes.length;
            const avgLng = longitudes.reduce((sum, lng) => sum + lng, 0) / longitudes.length;

            var map = L.map('map', {
                center: [avgLat, avgLng],
                zoom: 4,
            });

            L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
                subdomains: ['a', 'b', 'c']
            }).addTo(map);

            cities.forEach(city => {
                L.marker([city.latitude, city.longitude])
                    // .bindTooltip(city.name, {
                    //     direction: 'top',
                    //     sticky: false,
                    //     offset: [0, -15],
                    // })
                    .addTo(map)
                    .bindPopup(city.name)
                    .openPopup();

            });
        }

        function renderCountriesInfo(country) {
            const countryDiv = document.getElementById('country');
            countryDiv.classList.add('country-container');
            let content = `
            <p><h1>${country.flag_emoji} ${country.name}</h1></p>
            `;

            if (country.photo && country.photo.length > 0) {
                content += `
                <div class="country-imgs-container">
            <img src="${country.photo}" alt="Photo of ${country.name}" class="country-img"></div>
                `;
            }

            if (country.about && country.about.length > 0) {
                content += `
                <p>${country.about}</p>
                `;
            }

            if (country.show_regions) {
                content += `<div class="regions-container">`
                country.regions.forEach(region => {
                    content += `
                    <div class="region-container">
                        <h2 class="region-name">${region.name}</h2>`;

                    content += `<div class="cities-container">`;

                    region.cities.forEach(city => {
                        content += renderCity(city);
                    });
                    content += `</div>`;
                    content += `</div>`;

                });
                content += `</div>`;
            } else {
                const allCities = country.regions.flatMap(region => region.cities);
                content += `
                    <h2>All Cities</h2>
                    <ul>
                `;
                allCities.forEach(city => {
                    content += renderCity(city);
                });
                content += `</ul>`;
            }

            content += `<div id="map" style="height: 700px; border: 1px solid #AAA;"></div>`;
            countryDiv.innerHTML = content;

            const citiesWithCoords = country.regions.flatMap(region => region.cities.filter(city => city.latitude && city.longitude));
            getPins(citiesWithCoords);
        }

        function renderCity(city) {
            let cityDiv = `<div class="city-container">`;

            if (city.small_photo && city.small_photo.length > 0) {
                cityDiv += `
            <img src="${city.small_photo}" alt="${city.name} Photo" class="city-img">`;
            } else {
                cityDiv += `<div class="city-img"></div>`;
            }

            cityDiv += `
            <div class="city-info"><p>
            <a href="../city/?id=${city.id}">${city.name}</a></p><p>
            (Places: ${city.place_count}, Events: ${city.event_count})</p>
            </div>
            </div>
            `;



            return cityDiv;
        }


        document.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            const id = urlParams.get('id');
            fetchCountry(id);
        });
    </script>
</body>

</html>