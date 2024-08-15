#!/bin/usr/env bash

set -eEuo pipefail

echo "* * * * * /usr/bin/php /var/www/html/index.php cron" | crontab -u www-data -

# mysql
mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/

mysqld --user=root &

# Wait for mysql to start
while ! mysqladmin ping --silent; do
    sleep 0.1 && echo -n .
done

mysql << EOF
create database atrocore;
CREATE USER 'atrocore_user'@'localhost' IDENTIFIED BY 'p@ssw0rd';
GRANT ALL ON atrocore.* TO atrocore_user@localhost WITH GRANT OPTION;
flush privileges;
EOF

service apache2 start

# Wait for apache to start
while ! curl --output /dev/null --silent --head --fail http://localhost; do
    sleep 0.1 && echo -n .
done

echo "atropim is slow!"
curl --cookie-jar cookies.txt -H "Accept-Language: en"  -H 'Content-Type: application/json' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/' -d '{"host":"127.0.0.1","dbname":"atrocore","user":"atrocore_user","password":"p@ssw0rd","port":"3306"}' -o 1.json -X POST http://localhost/api/v1/Installer/setDbSettings
sleep 1
curl --cookie-jar cookies.txt -H "Accept-Language: en"  -H 'Content-Type: application/json' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/' -d '{"username":"admin","password":"p@ssw0rd","confirmPassword":"p@ssw0rd"}' -o 1.json -X POST http://localhost/api/v1/Installer/createAdmin
sleep 1
echo "atropim is ready!"

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty