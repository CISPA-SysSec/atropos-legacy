--TEST--
SPL: SplFileObject::fgetss (bug 45216)
--CREDITS--
Perrick Penet <perrick@noparking.net>
#testfest phpcampparis 2008-06-07
--FILE--
<?php
$file = __DIR__ . '/foo.html';
file_put_contents($file, 'text 0<div class="tested">text 1</div>');
$handle = fopen($file, 'r');

$object = new SplFileObject($file);
var_dump($object->fgetss());
var_dump(fgetss($handle));
?>
--CLEAN--
<?php
unlink(__DIR__ . '/foo.html');
?>
--EXPECTF--
Deprecated: Function fgetss() is deprecated in %s on line %d
string(12) "text 0text 1"

Deprecated: Function fgetss() is deprecated in %s on line %d
string(12) "text 0text 1"
