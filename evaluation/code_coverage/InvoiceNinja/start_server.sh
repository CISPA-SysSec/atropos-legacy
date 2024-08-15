#!/bin/usr/env bash

set -eEuxo pipefail

ls -lah /tmp
mkdir -p /run/mysqld/
# chown mysql:mysql /run/mysqld/
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

a2enmod rewrite 
a2enmod actions 

echo '[+] Starting mysql...'
service mariadb restart

echo '[+] Starting apache'
service apache2 restart

mysqld --user=root &

# Wait for mysql to start
while ! mysqladmin ping --silent; do
    sleep 0.1 && echo -n .
done

mysql << EOF
CREATE DATABASE \`ninja\` CHARACTER SET = 'utf8' COLLATE = 'utf8_general_ci';
CREATE USER 'ninja'@'localhost' IDENTIFIED BY 'ninja';
GRANT ALL PRIVILEGES ON \`ninja\`.* TO 'ninja'@'localhost';
FLUSH PRIVILEGES;
EOF

echo 123; ls -lah /tmp
mysql -u ninja -pninja ninja < /db_dump.sql

# mkdir -p /var/www/html/storage 
chown -R www-data:www-data /var/www/html/
chmod -R g+s /var/www/html/
# chmod -R 775 /var/www/html/storage

touch /tmp/php_errors.log
chmod 777 /tmp/php_errors.log
tail -f /tmp/php_errors.log &

# su - ${INVOICENINJA_USER} -s /bin/bash -c "/start.sh"

# apache2-foreground &

# cd ninja

# php artisan key:generate
# php artisan migrate
# php artisan migrate:fresh -n --seed
# php artisan migrate -n --seed
# php artisan optimize
# php artisan db:seed -n
# php artisan ninja:create-test-data -n
# cat .env
# php artisan config:clear
# mv .env .env.bak
# whoami
# pwd
service apache2 start
# cat storage/logs/laravel.log
# tail -f storage/logs/laravel.log &
# sleep 1
# php artisan serve --host=0.0.0.0 --port=80 &

# Wait for app to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80; do
    sleep 1
done

# admin@admin.com
# p@ssw0rd

# /venv/bin/python /set_up.py

# curl 'http://localhost/public/setup' -L -i -c /tmp/curl_cookies -b /tmp/curl_cookies

# cat /tmp/curl_cookies

# curl 'http://localhost/public/setup' -L -i -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/public/setup' -H 'Cookie: nc_sameSiteCookielax=true; nc_sameSiteCookiestrict=true; nc_username=nextcloud; nc_token=03lNEuAANEBXD%2Fwt%2Bux8Gs4dCp9aucxO' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'DNT: 1' -H 'Sec-GPC: 1' --data-raw 'app%5Burl%5D=http%3A%2F%2Flocalhost%3A3456%2Fpublic&https=0&debug=0&database%5Btype%5D%5Bhost%5D=localhost&database%5Btype%5D%5Bdatabase%5D=ninja&database%5Btype%5D%5Busername%5D=ninja&database%5Btype%5D%5Bpassword%5D=ninja&mail%5Bdriver%5D=smtp&mail%5Bfrom%5D%5Bname%5D=&mail%5Bfrom%5D%5Baddress%5D=&mail%5Busername%5D=&mail%5Bhost%5D=&mail%5Bport%5D=587&mail%5Bencryption%5D=tls&mail%5Bpassword%5D=&mail%5Bmailgun_domain%5D=&mail%5Bmailgun_secret%5D=&first_name=admin&last_name=admin&email=admin%40admin.com&password=p%40ssw0rd&terms_checkbox=0&terms_checkbox=1&privacy_checkbox=0&privacy_checkbox=1&_token=1tmJSC67LXhIixjpY6B9zflz0xoSBf8rjFpKxMC5' || true

# curl 'http://localhost/setup' -i -c /tmp/curl_cookies -b /tmp/curl_cookies

# curl 'http://localhost/setup' -i -L -c /tmp/curl_cookies -b /tmp/curl_cookies -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/117.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/setup' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'DNT: 1' -H 'Sec-GPC: 1' --data-raw 'app%5Burl%5D=http%3A%2F%2Flocalhost&https=0&debug=0&database%5Btype%5D%5Bhost%5D=localhost&database%5Btype%5D%5Bdatabase%5D=ninja&database%5Btype%5D%5Busername%5D=ninja&database%5Btype%5D%5Bpassword%5D=ninja&mail%5Bdriver%5D=smtp&mail%5Bfrom%5D%5Bname%5D=&mail%5Bfrom%5D%5Baddress%5D=&mail%5Busername%5D=&mail%5Bhost%5D=&mail%5Bport%5D=587&mail%5Bencryption%5D=tls&mail%5Bpassword%5D=&mail%5Bmailgun_domain%5D=&mail%5Bmailgun_secret%5D=&first_name=Test&last_name=User&email=test%40philipp-goerz.com&password=p%40ssw0rd&terms_checkbox=0&terms_checkbox=1&privacy_checkbox=0&privacy_checkbox=1&_token=4kI0NAhxhG0a11PeIgn6qKSuiTCDe2ouLr1szVqt'

# comment out if you don't need webfuzz instrumentation:
ls -lah /instr
runuser -u www-data -- cp -pr /var/www/html /instr/
runuser -u www-data -- php /instr/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /instr/html
rm -rf /instr/php-instrumentor; rm -rf /var/www/html; rm -rf /instr/html
mv /instr/html_instrumented /var/www/html

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty
