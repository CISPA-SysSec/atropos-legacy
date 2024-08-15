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
create database alto;
create user alto@localhost identified by 'p@ssw0rd';
grant all on alto.* to alto@localhost;
flush privileges;
EOF

cat /etc/apache2/sites-enabled/000-default.conf
service apache2 start

# Wait for app to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80; do
    sleep 0.1 && echo -n .
done
curl --cookie-jar cookies.txt  -H "Accept-Language: en" -d "install_env_params=1&install_step_next=Next" -X POST http://localhost/install/
phpsessid=`cat cookies.txt | grep -oP 'PHPSESSID\s+\K\w+'`
curl --cookie-jar cookies.txt -H "Accept-Language: en" -H "Cookie: PHPSESSID=${phpsessid}; " -d "install_db_params=1&install_db_server=localhost&install_db_port=3306&install_db_name=alto&install_db_user=alto&install_db_password=p%40ssw0rd&install_db_prefix=prefix_&install_db_engine=InnoDB&install_step_next=Next" -X POST http://localhost/install/
curl --cookie-jar cookies.txt -H "Accept-Language: en" -H "Cookie: PHPSESSID=${phpsessid}; " -d "install_admin_params=1&install_admin_login=admin&install_admin_mail=admin%40admin.adm&install_admin_pass=p%40ssw0rd&install_admin_repass=p%40ssw0rd&install_step_next=Next" -X POST http://localhost/install/
patch -u /var/www/html/app/config/config.local.php -i /config.local.php.patch
patch -u /var/www/html/index.php -i /index.php.patch
rm -r /var/www/html/install
sleep 2
curl --cookie-jar cookies.txt http://localhost > test.html
visitor_id=`cat cookies.txt | grep -oP 'visitor_id\s+\K\w+'`
security_key=`cat test.html | grep ALTO_SECURITY_KEY | grep -oP "'\K\w+"`
phpsessid=`cat test.html | grep SESSION_ID | grep -oP "'\K\w+"`
curl --cookie-jar cookies2.txt -H "Accept-Language: en" -H "Cookie: visitor_id=${visitor_id}; PHPSESSID=${phpsessid}; " -d "login=user&mail=a%40a.com&password=p%40ssw0rd&password_confirm=p%40ssw0rd&captcha=123&return-path=http%3A%2F%2Flocalhost%2F&security_key=${security_key}" -X POST http://localhost/registration/ajax-registration/

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

rm /dev/shm/webfuzz_cov.txt || true;
read -r -d '' _ </dev/tty
