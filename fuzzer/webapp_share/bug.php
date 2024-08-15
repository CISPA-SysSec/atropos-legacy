<?php
function die_error($str) {
    die($str);
}

function get_var($type, $var) {
    $m = ["GET" => $_GET, "POST" => $_POST, "COOKIE" => $_COOKIE, "SERVER" => $_SERVER];
    return $m[$type][$var];
}

error_reporting(0); // error display is disabled to check if bug oracle works independently

// try to confuse the array access feedback to see if it's overwhelmed
foreach (range(0, 100) as $number) {
    echo htmlspecialchars(get_var("GET", $number));
}

// bugs can only be accessed through second-order vulnerabilities (execute first with ?second=order and then you can trigger)
if(file_exists("second.txt")) {
    // test RCE but also substr feedback
    if(substr(get_var("GET", 'bug'), 5) == "rce_shell") {
        echo "command execution test\n";
        exec("cat 123 " . get_var("COOKIE", 'cmd'));
    } elseif(get_var("GET", 'bug') == "rce_eval") {
        // php code execution
        // test the preg_match redqueen feedback
        if(preg_match('/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,3})$/', get_var("GET", 'email'))) {
            echo "php code execution test\n";
            eval("\$myvar = '".get_var("POST", 'eval')."';");
            echo $myvar;
        }
    } elseif(get_var("GET", 'bug') == "file_inclusion") {
        // local file inclusion
        echo "local file inclusion test\n";
        if(get_var("GET", 'page') != "") {
            $path = "dvwa/".get_var("GET", 'page').".php";
            if(file_exists($path))
                include($path); // check if we find LFI by including "crash.php"
            else
                include($path); // check if we find LFI by generating a "no such file" error
        }
    } elseif($_GET['bug']['type'] == "unserialize") {
        // ^ this also tries an array input, i.e. requires bug.php?bug[type]=unserialize
        if(isset($_GET['data'])) {
            echo unserialize(get_var("GET", 'data'));
        }
    } elseif (get_var("GET", 'bug') == "SSRF") {
        // test arbitrary file read
        // but also partial preg_match feedback
        $domain = substr(get_var("GET", 'domain'), 7);
        if(preg_match('/((http|https)\:\/\/)?[a-zA-Z0-9\.\/\?\:@\-_=#]+\.([a-zA-Z0-9\&\.\/\?\:@\-_=#])*/', $domain)) {
            echo file_get_contents($domain);
        }
    } elseif (get_var("GET", 'bug') == "file_read") {
        // test arbitrary file read
        if(file_exists(get_var("GET", "page"))) {
            echo file_get_contents(get_var("GET", "page"));
        }
    }
    elseif (get_var("GET", 'bug') == "file_write") {
        // arbitrary file write vulnerability
        if(is_file(get_var("COOKIE", "page")) && strpos(get_var("COOKIE", 'page'), "bug.php") === false) {
            $fp = fopen(get_var("COOKIE", 'page'), "w+");
            fwrite($fp, get_var("GET", 'write'));
            fclose($fp);
        }
    } elseif(get_var("GET", 'bug') == "sql_injection") {
        // sql injection
        echo "sql injection test\n";
        define( 'DVWA_WEB_PAGE_TO_ROOT', '/var/www/html/' );
        include("/var/www/html/config/config.inc.php");
        include("/var/www/html/dvwa/includes/dvwaPage.inc.php");
        //mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
        $conn = mysqli_connect( $_DVWA[ 'db_server' ],  $_DVWA[ 'db_user' ],  $_DVWA[ 'db_password' ], $_DVWA['db_database'], $_DVWA[ 'db_port' ]); 
        // Check connection
        if ($conn->connect_error) {
            die("Connection failed: " . $conn->connect_error);
        }

        $query  = "SELECT * FROM users WHERE user_id='".get_var("GET", 'id')."'";
        if(intval(get_var("GET", 'blind')) > 0) {
            echo "sqli blind mode\n";
            $result = mysqli_query($conn,  $query);
        } else {
            $result = mysqli_query($conn,  $query) or die("sql error\n");
        }
        if ($result) {
            var_dump($result);
            while($obj = $result->fetch_object()){
                echo "Found user " . $obj->first_name . "\n";
            }
            mysqli_free_result($result);
        } else {
            echo "No user with this ID found!\n";
        }
        $conn->close();
    } elseif(get_var("GET", "bug") == "upload") {
        // arbitrary upload vulnerability: can we upload a PHP file?
        // faulty check to see if it's an image file
        if($_FILES['fileToUpload']['type'] == "image/png") {
            //if(getimagesize($_FILES['fileToUpload']['tmp_name'])) {
                move_uploaded_file($_FILES['fileToUpload']['tmp_name'], $_FILES['fileToUpload']['name']);
            //}   
        }
    }
}
if(get_var("SERVER", 'HTTP_BLA') == "order") {
    // check if second order vulnerabilities work
    file_put_contents("second.txt", "1");
}
?>
