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
create database spaladb;
create user dbadmin@localhost identified by 'p@ssw0rd';
grant all on spaladb.* to dbadmin@localhost;
flush privileges;
EOF

cd /var/www/html
php artisan key:generate
php artisan jwt:secret --force
php artisan migrate
npm run dev
chown -R www-data:www-data /var/www/html
chgrp -R www-data storage bootstrap/cache
chmod -R 777 storage public/uploads public/images bootstrap/cache
php artisan install
chown -R www-data:www-data /var/www/html
chgrp -R www-data storage bootstrap/cache
chmod -R 777 storage public/uploads public/images bootstrap/cache

service apache2 start

# Wait for apache to start
while ! curl --output /dev/null --silent --fail --head http://localhost:80/js/app.js; do
    sleep 0.1 && echo -n .
done

curl --cookie-jar cookies.txt -H "Accept-Language: en"  -H 'Content-Type: application/json' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/' -d '{"email":"admin@admin.com","password":"p@ssw0rd","password_confirmation":"p@ssw0rd","first_name":"admin","last_name":"admin"}' -o register.html -X POST http://localhost/api/auth/register
sleep 0.1
echo "spala is ready!"

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty