## Running Fuzzing Example with WordPress 5.6

#### 1. Instrument project 


```bash
   cd instrumentor/php/src
   php7.4 instrumentor.php --verbose --policy edge --method file --dir ~/webapps/WordPress
```
   
#### 2. Run the proxy to get JavaScript generated URLs


```bash
   cd webFuzz
   python3.8 webFuzz.py -w 8 
                        --meta ~/webapps/WordPress_instrumented/instr.meta 
                        --driver webFuzz/drivers/geckodriver 
                        -vv 
                        -p
                        -r simple 
                        'http://localhost/wp-admin/index.php' 
```
   
   + When the browser window starts, exercise as much of the functionality
     of the web app as possible (form submissions, anchor elements, etc.). 
   + Close the browser window when you are done. 
   + The fuzzer should start fuzzing now. 
     Regardless, terminate the fuzzing session (Ctrl+C)
   
   
#### 3. Start the actual fuzzing session


```bash
   cd webFuzz
   python3.8 webFuzz.py --ignore_4xx 
                        -w 8 
                        --meta ~/webapps/WordPress_instrumented/instr.meta 
                        --driver webFuzz/drivers/geckodriver 
                        -b 'wp-login.php|action|logout|*' 
                        -vv
                        --request_timeout 100 
                        --seed_file SEED_FILE 
                        -s 
                        --catch_phrase 'Howdy'
                        -r simple 
                        'http://localhost/wp-admin/index.php'
```
   
   + If step 2 was completed successfully a new seed file (in `./seeds` directory) should have been created.
     Call it SEED_FILE

   + The fuzzing session should now have started. 
     Check the file `./fuzzer.log` for more details.
   
   __Notes:__ 
   
   + The -b flag is to block sensitive urls such as logout links. 
     Find the logout url and any other sensitive link and block 
     them using this flag.

     The format is:
```
     -b '{needle in URL}|{needle in Parameter name}|{needle in Parameter value}|{Method: GET or POST or *}'
```
   
   + The --catch_phrase flag is needed to check if the fuzzer is still logged in. 
     Navigate to the entrypoint URL (http://localhost/wp-admin/index.php in this case), 
     and find a phrase in the html document that only appears if the user is logged in.
   
   + The -s flag opens a browser window for you to log-in the web app. As soon as you
     close the browser window, webFuzz will get the session cookies from the browser
