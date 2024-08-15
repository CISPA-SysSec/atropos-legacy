#!/bin/bash

set -x

# install necessary dependencies for composer
apt update
apt install -y unzip git php7.4-zip

# install composer
cd /tmp
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# download webfuzz instrumentor
runuser -u www-data git clone https://github.com/egueler/php-instrumentor.git
(cd php-instrumentor; runuser -u www-data composer install)

# instrument html code
runuser -u www-data -- cp -pr /var/www/html /tmp/
runuser -u www-data -- php /tmp/php-instrumentor/src/instrumentor.php --verbose --method file --policy edge --dir /tmp/html
rm -rf /tmp/php-instrumentor; rm -rf /var/www/html; rm -rf /tmp/html
mv /tmp/html_instrumented /var/www/html

cat /var/www/html/*.php

set -x