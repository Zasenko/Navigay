<?php
$host = "localhost";
$username = "u494568686_Zasenko";
$password = "&hEP!hEf5";
$dbname = "u494568686_NaviGay";

$con = mysqli_connect($host, $username, $password, $dbname);
if (mysqli_connect_errno())
{
    die("Failed to connect to MySQL: " . mysqli_connect_error());
}

return $con;
?>