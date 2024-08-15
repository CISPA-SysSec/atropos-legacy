--TEST--
Testing instanceof operator with several operators
--FILE--
<?php

$a = new stdClass;
var_dump($a instanceof stdClass);

var_dump(new stdCLass instanceof stdClass);

$b = create_function('', 'return new stdClass;');
var_dump($b() instanceof stdClass);

$c = array(new stdClass);
var_dump($c[0] instanceof stdClass);

var_dump(@$inexistent instanceof stdClass);

?>
--EXPECTF--
bool(true)
bool(true)

Deprecated: Function create_function() is deprecated in %s on line %d
bool(true)
bool(true)
bool(false)
