<?php
$XVWA_WEBROOT = "";
$host = "127.0.0.1";
$dbname = 'xvwa';
$user = "xvwa";
$pass = "p@ssw0rd";
$conn = new mysqli($host,$user,$pass,$dbname);
$conn1 = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
$conn1->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
?>
