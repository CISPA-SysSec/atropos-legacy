<!-- This file is used so the comparison to the web crawlers is more fair: Atropos has access to the directory structure and the sources of the PHP files whereas web crawlers would not have those otherwise. -->
<!DOCTYPE html>
<html>
<head>
    <title>List PHP Files</title>
</head>
<body>

<h1>PHP Files in Directory</h1>

<?php
function listPhpFiles($dir) {
    $files = scandir($dir);

    echo "<ul>";

    foreach ($files as $file) {
        if ($file == "." || $file == "..") continue;
        
        $path = $dir . '/' . $file;

        if (is_dir($path)) {
            echo "<li><strong>Directory: $file</strong>";
            listPhpFiles($path);
            echo "</li>";
        } else {
            if (pathinfo($file, PATHINFO_EXTENSION) === 'php') {
                echo "<li><a href='$path'>$file</a></li>";
            }
        }
    }

    echo "</ul>";
}

listPhpFiles('.');
?>

</body>
</html>
