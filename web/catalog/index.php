<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catalog</title>
    <meta name="description" content="Navigay offers a comprehensive catalog of gay events and venues across different countries and cities worldwide. Explore our curated selection of gay-friendly places and exciting events in various countries and cities.">
    <meta name="author" content="Dmitry Zasenko">
    <?php include('../header/head-icons.php'); ?>
    <link rel="stylesheet" type="text/css" href="../css/header.css">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        main {
            width: 100%;
            justify-content: center;
            max-width: 1000px;
            margin: auto;
            /* Добавляем свойство для центрирования */
        }

        .countries-main-container {
            gap: 2em;
            padding: 2em;
            display: grid;
        }

        .grouped-countries-container {
            display: flex;
            gap: 1em;
            padding-bottom: 2em;
            grid-column-gap: 1em;
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

        .letter-container {
            font-family: 'Roboto', sans-serif;
            font-size: 1em;
            font-weight: 900;
            padding-top: 0.4em;
            color: black;
            width: 1em;
        }

        .countries-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            border-left: 1px solid rgb(242, 242, 242);
            gap: 1.5em;
        }

        .country-container {
            display: flex;
            flex-direction: column;
        }

        .country-info-container {
            display: flex;
            padding-left: 1em;
        }

        .country-flag-container {
            width: 1.5em;
            font-family: 'Roboto', sans-serif;
            font-size: 1.5em;
            font-weight: 400;

        }

        .country-name-container {}

        /* Ваши оригинальные стили */
        .country-link {
            color: #2897ff !important;
            /* Используем !important, чтобы переопределить внешние стили */
            text-decoration: underline;
            font-family: 'Roboto', sans-serif;
            font-size: 1.5em;
            font-weight: 400;
        }

        .country-link:hover {
            color: black !important;
            text-decoration-line: underline;
        }

        h1 {
            padding-block: 0.5em;
        }

        .countries-text {
            padding-bottom: 2em;
            padding-inline: 2em;
            /*max-width: 1100px;*/
            /*margin: auto;*/
        }

        p {
            margin-bottom: 1em;
        }
    </style>
</head>

<body>
    <?php include('../header/header.php'); ?>
    <main>
        <h1>Countries</h1>
        <div class="countries-text">
            <p>Welcome to&nbsp;Navigay&rsquo;s comprehensive catalog of&nbsp;gay events and venues worldwide.
                Explore our curated selection of&nbsp;gay-friendly places and exciting events in&nbsp;various
                countries and cities.</p>
            <p>Whether you&rsquo;re looking for vibrant nightlife, cultural experiences,
                or&nbsp;community gatherings, Navigay is&nbsp;your ultimate guide to&nbsp;the global LGBTQ+ scene.
            </p>
        </div>
        <div id="countries" class="countries-main-container"></div>
    </main>
    <script>
        async function fetchCountries() {
            try {

                const url = `get-countries.php`;

                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error('Failed to fetch countries: ' + response.status);
                }

                const data = await response.json();

                if (data.result && data.countries) {
                    renderCountriesInfo(data.countries);
                } else {
                    throw new Error('Unexpected response format');
                }
            } catch (error) {
                console.error('Error fetching countries information:', error);
            }
        }

        function renderCountriesInfo(countries) {
            const countriesDiv = document.getElementById('countries');
            countriesDiv.innerHTML = ''; // Очищаем содержимое перед добавлением новых элементов

            // Создаем контейнеры для каждой группы стран
            for (const letter in countries) {

                const groupedContainer = document.createElement('div');
                groupedContainer.classList.add('grouped-countries-container');
                countriesDiv.appendChild(groupedContainer);

                // Добавляем контейнер для буквы
                const letterContainer = document.createElement('div');
                letterContainer.classList.add('letter-container');
                letterContainer.textContent = letter; // Добавляем текстовое содержимое - букву
                groupedContainer.appendChild(letterContainer);

                // Добавляем контейнер для стран
                const countriesContainer = document.createElement('div');
                countriesContainer.classList.add('countries-container');
                groupedContainer.appendChild(countriesContainer);

                // Добавляем страны в контейнер
                countries[letter].forEach(country => {
                    const countryContainer = document.createElement('div');
                    countryContainer.classList.add('country-container');
                    countryContainer.innerHTML = `
    
                        <div class="country-info-container">
                            <div class="country-flag-container">${country.flag_emoji}</div>
                            <div class="country-name-container">
                                <p>
                                    <a href="country/?id=${country.id}" class="country-link">${country.name}</a>
                                </p>
                                <p>
                                    place count: ${country.place_count}  /  event count: ${country.event_count}
                                </p>
                                
                                </div>
                        </div>
                `;
                    countriesContainer.appendChild(countryContainer);
                });
            }
        }



        // Fetch city information when the page loads
        document.addEventListener('DOMContentLoaded', () => {
            fetchCountries();
        });
    </script>


</body>

</html>