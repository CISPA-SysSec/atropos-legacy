#!/bin/bash

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

a2enmod rewrite 
a2enmod actions 

echo '[+] Starting mysql...'
service mariadb start

echo '[+] Starting apache'
service apache2 start

echo "[!] Press CTRL+C when you are finished with the web setup"
tail -f /var/log/apache2/*.log &

# idle waiting for abort from user
( trap exit SIGINT ; read -r -d '' _ </dev/tty ) ## wait for Ctrl-C
echo "[!] Instrumenting source code"
# webfuzz instrumentation
php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /var/www/html/
chown -R www-data:www-data /var/www/html_instrumented/
rm -rf /tmp/php-instrumentor;
echo "[!] Press CTRL+C when you are finished with the login"
mv /var/www/html /var/www/html_orig; mv /var/www/html_instrumented /var/www/html
# idle waiting for abort from user
( trap exit SIGINT ; read -r -d '' _ </dev/tty ) ## wait for Ctrl-C
cat /dev/shm/webfuzz_cov.txt
cp /dev/shm/webfuzz_cov.txt /
mv /var/www/html /var/www/html_instrumented; mv /var/www/html_orig /var/www/html
rm -rf /var/www/html_instrumented

# webfuzz instrumentation
# runuser -u www-data -- cp -pr /var/www/html /tmp/
# runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
# rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
# mv /tmp/html_instrumented /var/www/html

echo "[+] Dumping SQL database"

mysqldump --user=app --password=vulnerables --host=localhost dvwa --result-file=/dev/shm/dump.sql
chmod 777 /dev/shm/dump.sql

rm /var/www/html/03dde1bd-c6b6-4424-8618-c4488e30484a

service mariadb stop
service apache2 stop