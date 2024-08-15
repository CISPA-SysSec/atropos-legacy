<?php
$data = array("SERVER" => $_SERVER, "COOKIE" => $_COOKIE);
echo htmlspecialchars(json_encode($data, JSON_UNESCAPED_SLASHES));
?>