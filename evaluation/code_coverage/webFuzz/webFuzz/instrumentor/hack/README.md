# HACK-AST
to download libraries if not present (vendor dir) run:  
   `php composer.phar install`

to update autoload map run:  
   `hhvm vendor/bin/hh-autoload`

## Files  

- ast_function_echo.hack 
-> parses and modifies the ast tree
edit the input filename in the source file
creates instr.in-filename.hack
instrumented file

- login_page.hack 
-> not finished login page template
gives you an idea of xhp-lib
