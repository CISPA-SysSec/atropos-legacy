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
create database espocrmdb;
create user dbadmin@localhost identified by 'p@ssw0rd';
grant all on espocrmdb.* to dbadmin@localhost;
flush privileges;
EOF

service apache2 start

wget http://localhost:80/espocrm/install/ -O -

while ! curl --output /dev/null  --cookie-jar cookie_get.txt --silent --head --fail http://localhost:80/espocrm/install/; do
    sleep 0.1 && echo -n .
done

ls -lah
cat cookie_get.txt
cat cookie_get.txt | grep -oP 'PHPSESSID\s+\K\w+'
phpsessid=`cat cookie_get.txt | grep -oP 'PHPSESSID\s+\K\w+'`

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "user-lang=en_US&theme=Espo&action=step1" -o step1.html -X POST http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "license-agree=1&action=step2" -o step2.html -X POST http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "dbName=espocrmdb&hostName=127.0.0.1%3A3306&dbUserName=dbadmin&dbUserPass=p%40ssw0rd&action=settingsTest" -X POST -o step2_test.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "host-name=127.0.0.1%3A3306&db-name=espocrmdb&db-user-name=dbadmin&db-user-password=p%40ssw0rd&action=setupConfirmation" -X POST -o step2_confirm.html http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "action=step3" -X POST -o step3.html http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "user-name=admin&user-pass=p%40ssw0rd&user-confirm-pass=p%40ssw0rd&action=savePreferences" -X POST -o step4.html http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "user-name=admin&user-pass=p%40ssw0rd&user-confirm-pass=p%40ssw0rd&action=step4" -X POST -o step4.html http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "action=checkPermission" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "action=saveSettings" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "action=buildDatabase" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "name=admin&pass=p%40ssw0rd&confPass=p%40ssw0rd&user-name=admin&user-pass=p%40ssw0rd&action=createUser" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "dateFormat=DD.MM.YYYY&timeFormat=HH%3Amm&timeZone=UTC&weekStart=0&defaultCurrency=USD&thousandSeparator=%2C&decimalMark=.&language=en_US&action=step5" -o step5.html -X POST http://localhost/espocrm/install/
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "smtpServer=&smtpPort=587&smtpAuth=false&smtpSecurity=TLS&smtpUsername=&smtpPassword=&outboundEmailFromName=EspoCRM&outboundEmailFromAddress=&outboundEmailIsShared=true&action=saveEmailSettings" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "dateFormat=DD.MM.YYYY&timeFormat=HH%3Amm&timeZone=UTC&weekStart=0&defaultCurrency=USD&thousandSeparator=%2C&decimalMark=.&language=en_US&action=savePreferences" -X POST -o saveSettings.html http://localhost/espocrm/install/index.php
sleep 0.1

curl -H "Accept-Language: en"  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost' -H 'Connection: keep-alive' -H 'Referer: http://localhost/espocrm/install/' -H 'Upgrade-Insecure-Requests: 1'  -H "Cookie: PHPSESSID=${phpsessid}; " -d "outboundEmailFromName=EspoCRM&outboundEmailFromAddress=&outboundEmailIsShared=on&smtpServer=&smtpPort=587&smtpSecurity=TLS&smtpUsername=emailuser&smtpPassword=p%40ssw0rd&action=finish" -X POST -o finish.html http://localhost/espocrm/install/
sleep 0.1

cd /var/www/html/espocrm; /usr/local/bin/php -f cron.php > /dev/null 2>&1

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

rm /dev/shm/webfuzz_cov.txt || true;
echo "Server started!"

read -r -d '' _ </dev/tty
