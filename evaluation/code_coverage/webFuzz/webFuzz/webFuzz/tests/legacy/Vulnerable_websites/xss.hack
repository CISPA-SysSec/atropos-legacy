namespace Hack\GettingStarted\XSS;

/**
 * This class illustrates an example of a vulnerability to 
 * cross site scripting (XSS) which can be exploited through
 * a URL that will give as a parameter the magic number needed
 * to executed the malicious script. This script is passed through
 * the name parameter.
 * 
 * Run HHVM in server mode: sudo hhvm -m server -p 8080 -vServer.AllowRunAsRoot=1
 * A malicious web request must be of the form: 
 * http://localhost:8080/xxs.hack?a=5&name=<script>alert(1)</script>
 * Author: Marcos Antonios Charalambous
 */

/**
 * The method that will handle the get request.
 */
function handleGet(): void {
    $input = $_POST["name"];
    $a=$_POST["pass"];
    $magic_number=5;
    if ($a==$magic_number){
      echo $input." ";
      echo $a;
     }else{
      echo "Welcome to hack!";
    }
}

/**
 * The entry point to our program. Here we check 
 * what kind of request was made by the user.
 */
<<__EntryPoint>>
function main(): noreturn{
  if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    handleGet();
  }
  exit(0);
}
