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
create database nextcloud;
create user nextcloud@localhost identified by 'secure';
grant all on nextcloud.* to nextcloud@localhost;
flush privileges;
EOF

mysql -u"nextcloud" -p"secure" "nextcloud" < /nextcloud.sql

touch /tmp/php_errors.log
chmod 777 /tmp/php_errors.log
tail -f /tmp/php_errors.log &

service apache2 start

# Wait for apache to start
while ! curl --output /dev/null --silent --head --fail http://localhost:80; do
    sleep 0.1 && echo -n .
done

# setup mail extension
#su - www-data -s /bin/bash -c 'cd html/apps/mail && php /app/composer.phar update'
su - www-data -s /bin/bash -c 'cd html && php occ app:enable mail'

# comment out if you don't need webfuzz instrumentation:
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

echo "Server started!"

rm /dev/shm/webfuzz_cov.txt || true;
read -r -d '' _ </dev/tty

# admin:
# nextcloud
# secure

# user:
# user1
# securecloud


# http://localhost:3456/apps/mail/vendor/cerdic/css-tidy/css_optimiser.php

# two links
