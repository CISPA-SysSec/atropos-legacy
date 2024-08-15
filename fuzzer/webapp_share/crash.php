<?php
$secret = "secret4815162342";
$including_file      = debug_backtrace()[0]['file'];
$included_file_line  = debug_backtrace()[0]['line'];
if($including_file != "") {
    file_put_contents("/tmp/bug_triggered", "bug oracle triggered: validated lfi in ".$including_file.":".$included_file_line, FILE_APPEND);
} else {
    file_put_contents("/tmp/bug_triggered", "bug oracle triggered: validated lfi ", FILE_APPEND);
}

?>