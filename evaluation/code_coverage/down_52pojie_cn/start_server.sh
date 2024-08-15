#!/bin/usr/env bash

set -eEuo pipefail


service apache2 start

cd /var/www/html
php php/scan.php
sleep 0.1

# Wait for apache to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80/; do
    sleep 0.1 && echo -n .
done

echo "down_52pojie is ready!"

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty