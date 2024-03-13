<?php

function getOrCreateCountryId($conn, $isoCountryCode, $country_name, $country_name_eng)
{
    $sql = "SELECT id FROM Country WHERE isoCountryCode = ? LIMIT 1";
    $params = [$isoCountryCode];
    $types = "s";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $country_result = $stmt->get_result();
    $stmt->close();

    if ($country_result->num_rows > 0) {
        $row = $country_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO Country (isoCountryCode, name_origin, name_en) VALUES (?, ?, ?)";
        $params = [$isoCountryCode, $country_name, $country_name_eng];
        $types = "sss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (isoCountryCode: ' . $isoCountryCode . ', country name: ' . $country_name . ', country name eng :' . $country_name_eng . ') into Country table.')) {
            return getLastInsertId($conn);
        }
    }
}
function getOrCreateRegionId($conn, $country_id, $region_name, $region_name_eng)
{
    $sql = "SELECT id FROM Region WHERE country_id = ? AND (name_origin = ? OR (name_origin IS NULL AND ? IS NULL)) LIMIT 1";
    $params = [$country_id, $region_name, $region_name];
    $types = "iss";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $region_result = $stmt->get_result();
    $stmt->close();

    if ($region_result->num_rows > 0) {
        $row = $region_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO Region (country_id, name_origin, name_en) VALUES (?, ?, ?)";
        $params = [$country_id, $region_name, $region_name_eng];
        $types = "iss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country_id: ' . $country_id . ', region name: ' . $region_name . ', region name eng :' . $region_name_eng . ') into Region table.')) {
            return getLastInsertId($conn);
        }
    }
}
function getOrCreateCityId($conn, $country_id, $region_id, $city_name, $city_name_eng)
{
    $sql = "SELECT id FROM City WHERE country_id = ? AND region_id = ? AND name_origin = ? LIMIT 1";
    $params = [$country_id, $region_id, $city_name];
    $types = "iis";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $city_result = $stmt->get_result();
    $stmt->close();

    if ($city_result->num_rows > 0) {
        $row = $city_result->fetch_assoc();
        return $row["id"];
    } else {
        $sql = "INSERT INTO City (country_id, region_id, name_origin, name_en) VALUES (?, ?, ?, ?)";
        $params = [$country_id, $region_id, $city_name, $city_name_eng];
        $types = "iiss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country id: ' . $country_id . ', region id: ' . $region_id . ', city name :' . $city_name . ', city name eng :' . $city_name_eng . ') into City table.')) {
            return getLastInsertId($conn);
        }
    }
}
