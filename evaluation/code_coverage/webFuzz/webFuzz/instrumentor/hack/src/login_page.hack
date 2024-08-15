namespace srec\login;

require_once('./../vendor/autoload.hack');

use function Facebook\FBExpect\expect;

function login_main() : noreturn {
   \Facebook\AutoloadMap\initialize();
   \setcookie("session", \bin2hex(\random_bytes(16)), 0, "/", "localhost", false, false);
   $x = null;
   
   try {
     expect($x)->toNotBeNull();
   } catch (\Facebook\HackTest\ExpectationFailedException $e) {
      echo "exection caught\n";
      $x = "empty";
   } finally {
      echo $x;
   }
   check_credentials();
   echo 
      <x:doctype>
         <html>
            {head()}
            {body()}
         </html>
      </x:doctype>;
   exit(0);
}

function check_credentials() : bool {
   // in reality we would contact out db here
   if (isset($_COOKIE["session"])) {
      return true;     
   }
   return false;

}
function head() : \xhp_head {
   return
      <head>
         <meta charset="utf-8"/>
         <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
         <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
         <meta name="description" content="test page for xss"/>
         <meta name="author" content="ovr"/>
         <title>Login Page</title>
      </head>;
}

function body() : \xhp_body {
   
   $cookie = $_COOKIE["session"] ?? "none";   
   return
      <body>
         <p>
            This is a paragraph {\srec\modules\myfun1()}
            Your cookie is: {$cookie}
         </p>
      </body>;
}
