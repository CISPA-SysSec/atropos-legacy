# PHP Scanner docker images
> Automated scanning and parsing of PHP code using dockerized open source PHP code scanners

## scan.py for scanning
Use scan.py for scanning php code with specified scanners. The script will also automatically call parse.py to parse the results. 

**-s/--scanner: (required)** Define one or more scanner(s) to be used (exakat, phpcs, progpilot, rips, sonarsource, all). Choosing 'all' will execute all scanners

**-i/--input: (required)** Define path which contains code to be scanned. Use _dvwa_ to clone the [DVWA repository](https://github.com/digininja/DVWA) and scan it

**-h:** Show help

#### Example: `python3 scan.py -s rips -i /path/to/code`

## parse.py for parsing

Since scan.py automatically runs parse.py, there is no need to run it manually. Nethertheless, it is possible to do so.

**-s/--scanner: (required):** Define one or more scanner(s) to parse their results (exakat, phpcs, progpilot, rips, sonarsource, all). Choosing 'all' will parse all scanner results

**-i/--input: (optional)** Define path(s) containing scan results of selected scanners. Number of selected scanners through -s must match number of given input paths. If this option is not used, default paths will be used

#### Example: `python3 parse.py -s exakat`

## How it works:

1. Copy code to be scanned into a defined local directory. This is due to some scanners having side effects (generate metadata in code directory etc.)
2. Build docker image for specified scanner(s). Respective dockerfiles can be found in image_\{SCANNER_NAME\} directory of this git repository.
3. Remove old container (from previous scans) to guarantee unused container
4. Execute scanner with `docker run ...` and wait for it to finish
5. Call parse.py parsing the scan results into a structured form
6. Print results in structured form and save it to disk as JSON string

## Currently covering:
* [RIPS](https://www.ripstech.com/) (latest open source version 0.55)
* [Sonarqube](https://www.sonarqube.org/) (community edition)
* [Exakat](https://www.exakat.io/) (community edition)
* [Progpilot](https://github.com/designsecurity/progpilot)
* [phpcs-security-audit](https://github.com/FloeDesignTechnologies/phpcs-security-audit)
