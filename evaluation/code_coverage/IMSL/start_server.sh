#!/bin/usr/env bash

set -eEuo pipefail

# mariadb
mkdir -p /run/mysqld/
chown mysql:mysql /run/mysqld/

mysqld &

# Wait for mysql to start
while ! mysqladmin ping --silent; do
    sleep 0.1 && echo -n .
done

mysql << EOF
create database imsldb;
create user dbadmin@localhost identified by 'p@ssw0rd';
grant all on imsldb.* to dbadmin@localhost;
flush privileges;
EOF


service apache2 start

cd /var/www/html
sed -i "s|./helpers|./Helpers|" resources/js/app.js

php artisan key:generate
php artisan migrate --seed --force
chown -R www-data:www-data /var/www/html
npm install && npm run prod

# Wait for apache to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80/; do
    sleep 0.1 && echo -n .
done
curl --cookie-jar cookies.txt -H "Accept-Language: en"  -H 'Content-Type: application/json' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/' -d '{"name":"admin","email":"admin@admin.com","password":"p@ssw0rd","password_confirmation":"p@ssw0rd"}' -o register.html -X POST http://localhost/api/auth/register
sleep 0.1
echo "IMSL is ready!"

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty