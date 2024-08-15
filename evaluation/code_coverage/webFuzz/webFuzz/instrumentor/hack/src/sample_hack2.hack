#!/usr/bin/env hhvm

<<__EntryPoint>>
function main(): noreturn {
  echo "Hello World\n";
  $e = "hoho";
  \print_r($e);  
  
  while (true)
     echo "hohoho";

  foreach ($_GET as $_ => $val)
     echo $val . "\n";
  exit(0);
}
