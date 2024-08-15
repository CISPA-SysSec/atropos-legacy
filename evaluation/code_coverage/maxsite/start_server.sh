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
create database cms;
create user cms@localhost identified by 'p@ssw0rd';
grant all on cms.* to cms@localhost;
flush privileges;
EOF

cat /etc/apache2/sites-enabled/000-default.conf
service apache2 start

# Wait for app to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80; do
    sleep 0.1 && echo -n .
done

# to create .htaccess application/maxsite/mso_config.php robots.txt sitemap.xml
curl -H "Accept-Language: en" -d "username=cmsuser&password=p@ssw0rd&email=test@test.com&site_name=cmssite&db_hostname=localhost&db_username=cms&db_password=p@ssw0rd&db_database=cms&db_dbprefix=mso_" -X POST http://localhost/install/

if [ ! -f "/var/www/html/application/config/database.php" ]; then
    echo "failed to initilialize, check if /var/www/html/application/config/database.php is writable."
    exit 1
fi

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

rm /dev/shm/webfuzz_cov.txt || true;

read -r -d '' _ </dev/tty
