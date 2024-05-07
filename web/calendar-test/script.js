document.addEventListener('DOMContentLoaded', function () {
    const calendarContainer = document.getElementById('calendarContainer');
    const showCalendarBtn = document.getElementById('showCalendarBtn');

    // Обработчик события для кнопки "Показать календарь"
    showCalendarBtn.addEventListener('click', function () {
        // Переключаем видимость контейнера календаря
        calendarContainer.classList.toggle('show');

        // Если контейнер календаря теперь видим, инициализируем календарь
        if (calendarContainer.classList.contains('show')) {
            // Инициализация календаря...
            var eventDates = {}
            let day1 = formatDate(new Date(new Date().setMonth(new Date().getMonth() + 1)))
            eventDates[day1] = [
                'Event 1, Location',
                'Event 2, Location 2'
            ]
            let day2 = formatDate(new Date(new Date().setDate(new Date().getDate() + 40)))
            eventDates[day2] = [
                'Event 2, Location 3',
            ]

            var maxDate = {
                1: new Date(new Date().setMonth(new Date().getMonth() + 11)),
                2: new Date(new Date().setMonth(new Date().getMonth() + 10)),
                3: new Date(new Date().setMonth(new Date().getMonth() + 9))
            }

            var flatpickr = $('#calendar .placeholder').flatpickr({
                inline: true,
                minDate: 'today',
                maxDate: maxDate[3],
                showMonths: 1,
                enable: Object.keys(eventDates),
                disableMobile: "true",
                onChange: function (date, str, inst) {
                    var contents = '';
                    if (date.length) {
                        for (i = 0; i < eventDates[str].length; i++) {
                            contents += '<div class="event"><div class="date">' + flatpickr.formatDate(date[0], 'l J F') + '</div><div class="location">' + eventDates[str][i] + '</div></div>';
                        }
                    }
                    $('#calendar .calendar-events').html(contents)
                },
                locale: {
                    weekdays: {
                        shorthand: ["S", "M", "T", "W", "T", "F", "S"],
                        longhand: [
                            "Sunday",
                            "Monday",
                            "Tuesday",
                            "Wednesday",
                            "Thursday",
                            "Friday",
                            "Saturday",
                        ]
                    }
                }
            });

            // Применяем функцию изменения размера при изменении размера окна
            eventCaledarResize($(window));
            $(window).on('resize', function () {
                eventCaledarResize($(this))
            });
        } else {
            // Если контейнер календаря скрыт, очищаем его содержимое
            $('#calendar .calendar-events').html('');
        }
    });

    // Функция изменения размера календаря в зависимости от ширины окна
    function eventCaledarResize($el) {
        var width = $el.width();
        if (flatpickr && flatpickr.selectedDates.length) {
            flatpickr.clear();
        }
        if (width >= 992 && flatpickr.config.showMonths !== 3) {
            flatpickr.set('showMonths', 3);
            flatpickr.set('maxDate', maxDate[3]);
        }
        if (width < 992 && width >= 768 && flatpickr.config.showMonths !== 2) {
            flatpickr.set('showMonths', 2);
            flatpickr.set('maxDate', maxDate[2]);
        }
        if (width < 768 && flatpickr.config.showMonths !== 1) {
            flatpickr.set('showMonths', 1);
            flatpickr.set('maxDate', maxDate[1]);
            $('.flatpickr-calendar').css('width', '');
        }
    }

    // Функция форматирования даты
    function formatDate(date) {
        let d = date.getDate();
        let m = date.getMonth() + 1; //Month from 0 to 11
        let y = date.getFullYear();
        return '' + y + '-' + (m <= 9 ? '0' + m : m) + '-' + (d <= 9 ? '0' + d : d);
    }
});
