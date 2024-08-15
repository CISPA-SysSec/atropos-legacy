#!/bin/usr/env bash

set -eEuo pipefail

mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/

mysqld &

# Wait for mysql to start
while ! mysqladmin ping --silent; do
    sleep 0.1 && echo -n .
done

mysql << EOF
create database dvwa;
create user dvwa@localhost identified by 'p@ssw0rd';
grant all on dvwa.* to dvwa@localhost;
flush privileges;
EOF

service apache2 start

# Wait for apache to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80; do
    sleep 0.1 && echo -n .
done

echo "Before set_up.py"
mysql << EOF
select distinct * from information_schema.columns where table_schema = 'dvwa';
EOF

/venv/bin/python /set_up.py

echo "After set_up.py"
mysql << EOF
select distinct * from information_schema.columns where table_schema = 'dvwa';
EOF

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

rm /dev/shm/webfuzz_cov.txt || true;

echo "DVWA is ready!"

read -r -d '' _ </dev/tty
