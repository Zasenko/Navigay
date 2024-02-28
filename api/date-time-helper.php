<?php

function convertToMySQLDate($dateString)
{
    try {
        $dateTime = new DateTime($dateString);
        return $dateTime->format('Y-m-d');
    } catch (Exception $e) {
        sendError('Error converting date: ' . $e->getMessage());
    }
}
function convertToMySQLTime($timeString)
{
    try {
        $dateTime = new DateTime($timeString);
        return $dateTime->format('H:i');
    } catch (Exception $e) {
        sendError('Error converting time: ' . $e->getMessage());
    }
}
