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
create database laravelvuespadb;
create user dbadmin@localhost identified by 'p@ssw0rd';
grant all on laravelvuespadb.* to dbadmin@localhost;
flush privileges;
EOF

cd /var/www/html
composer create-project --prefer-dist cretueusebiu/laravel-vue-spa || true
php artisan key:generate 
php artisan jwt:secret --force 
php artisan migrate
npm install
chown -R www-data:www-data /var/www/html
chgrp -R www-data storage bootstrap/cache
chmod -R 777 storage bootstrap/cache
service apache2 start
npm ci
npm run build &

# Wait for apache to start
while ! curl --output /dev/null --silent --fail --head http://localhost:80/; do
    sleep 0.1 && echo -n .
done

curl -H "Accept-Language: en" -H "Accept: application/json, text/plain, */* "-H "Host: localhost" -H "sec-gpc: 1" -H "Content-Type: application/json;charset=UTF-8" -H "Accept-Encoding: gzip, deflate" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36" -H "Cookie: locale=en" -H "Dnt: 1" -H "Origin: http://localhost" -H "Referer: http://localhost/register" -H "Host:localhost" -d '{"name":"admin","email":"admin@admin.com","password":"p@ssw0rd","password_confirmation":"p@ssw0rd"}' -X POST http://localhost/api/register

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty
