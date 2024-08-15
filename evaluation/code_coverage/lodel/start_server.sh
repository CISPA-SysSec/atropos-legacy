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
CREATE DATABASE lodel CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
create user lodeluser@localhost identified by 'p@ssw0rd';
grant all on lodel.* to lodeluser@localhost;
flush privileges;
EOF

service apache2 start

# Wait for app to start
while ! curl --fail --cookie-jar cookies.txt -o install_cache.txt  http://localhost:80/lodeladmin/install.php; do
    sleep 0.1 && echo -n .
done

tmppasswd=`cat install_cache.txt | grep -oP "Password[:] [<]strong[>]\s*\K(\w+)"`
curl --cookie-jar cookies_login.txt -d "url_retour=%2Flodeladmin%2F&login=admin&passwd=${tmppasswd}" -X POST -o login_cache.txt http://localhost/lodeladmin/login.php 

sessionlodel=`cat cookies_login.txt | grep -oP "sessionlodel\s*\K(\w+)"`
curl -H "Content-Type: multipart/form-data;" -H "Cookie: sessionlodel=${sessionlodel}" -F do=edit -F lo=users -F id=0 -F username=lodeladmin -F passwd=p@ssw0rd -F confirmpasswd=p@ssw0rd -F email=test@test.com  -F lang=fr -F userrights=128 -F gui_user_complexity=128 -F protected=on  -X POST "http://localhost/lodeladmin/index.php?do=view&lo=users"

curl --cookie-jar cookies_login.txt -d "url_retour=%2Flodeladmin%2F&login=lodeladmin&passwd=p@ssw0rd" -X POST -o login_cache.txt http://localhost/lodeladmin/login.php 
sessionlodel=`cat cookies_login.txt | grep -oP "sessionlodel\s*\K(\w+)"`
curl -H "Content-Type: multipart/form-data;" -H "Cookie: sessionlodel=${sessionlodel}" "http://localhost/lodeladmin/index.php?do=delete&id=1&lo=users"

rm /var/www/html/03dde1bd-c6b6-4424-8618-c4488e30484a

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

rm /dev/shm/webfuzz_cov.txt
echo "Server started!"

read -r -d '' _ </dev/tty
