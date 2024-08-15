#!/bin/bash

rm /var/www/html/webfuzz_cov.txt
/coverage.sh &
/http.sh
/http.sh
/http.sh
SESSION=/dev/shm/session.json timeout -k 10 $TIMEOUT python3 webFuzz.py --ignore_4xx -w 8 --meta /var/www/html/instr.meta --driver webFuzz/drivers/geckodriver -vv -b $LOGOUT_B --catch_phrase $CATCH_PHRASE --request_timeout 100 -s -r simple $URL