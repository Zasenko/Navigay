<?php
function getOrCreateCountryId($conn, $isoCountryCode, $country_name_en)
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
        $sql = "INSERT INTO Country (isoCountryCode, name_en) VALUES (?, ?, ?)";
        $params = [$isoCountryCode, $country_name_en];
        $types = "ss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (isoCountryCode: ' . $isoCountryCode . ', country name eng :' . $country_name_en . ') into Country table.')) {
            return getLastInsertId($conn);
        }
    }
}

function getOrCreateRegionId($conn, $country_id, $region_name_en)
{
    $sql = "SELECT id, redirect_region_id FROM Region WHERE country_id = ? AND (name_origin_en = ? OR (name_origin_en IS NULL AND ? IS NULL)) LIMIT 1";

    $params = [$country_id, $region_name_en, $region_name_en];
    $types = "iss";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $region_result = $stmt->get_result();
    $stmt->close();

    if ($region_result->num_rows > 0) {
        $row = $region_result->fetch_assoc();
        if (!is_null($row["redirect_region_id"]) && is_int($row["redirect_region_id"]) && $row["redirect_region_id"] > 0) {
            return $row["redirect_region_id"];
        } else {
            return $row["id"];
        }
    } else {
        $sql = "INSERT INTO Region (country_id, name_origin_en, name_en) VALUES (?, ?, ?)";
        $params = [$country_id, $region_name_en, $region_name_en];
        $types = "iss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country_id: ' . $country_id . ', region name eng :' . $region_name_en . ') into Region table.')) {
            return getLastInsertId($conn);
        }
    }
}

function getOrCreateCityId($conn, $country_id, $region_id, $city_name_en)
{
    $sql = "SELECT id, redirect_city_id FROM City WHERE country_id = ? AND region_id = ? AND name_origin_en = ? LIMIT 1";
    $params = [$country_id, $region_id, $city_name_en];
    $types = "iis";
    $stmt = executeQuery($conn, $sql, $params, $types);
    $city_result = $stmt->get_result();
    $stmt->close();

    if ($city_result->num_rows > 0) {
        $row = $city_result->fetch_assoc();
        if (!is_null($row["redirect_city_id"]) && is_int($row["redirect_city_id"]) && $row["redirect_city_id"] > 0) {
            return $row["redirect_city_id"];
        } else {
            return $row["id"];
        }
    } else {
        $sql = "INSERT INTO City (country_id, region_id, name_origin_en, name_en) VALUES (?, ?, ?, ?)";
        $params = [$country_id, $region_id, $city_name_en, $city_name_en];
        $types = "iiss";
        $stmt = executeQuery($conn, $sql, $params, $types);
        if (checkInsertResult($stmt, $conn, 'Failed to insert data (country id: ' . $country_id . ', region id: ' . $region_id . ', city name eng :' . $city_name_en . ') into City table.')) {
            return getLastInsertId($conn);
        }
    }
}
