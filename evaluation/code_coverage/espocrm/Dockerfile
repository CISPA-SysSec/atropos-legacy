FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping libzip-dev libc-client-dev libkrb5-dev libzip-dev \
    # maria db \
    mariadb-server mariadb-client \
    nodejs npm \
    # other packages \
    git wget unzip \
    && rm -rf /var/lib/apt/lists/* 


RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \ 
    docker-php-ext-install \
    gd pdo json zip imap exif \
    pdo_mysql mysqli

COPY php.ini "$PHP_INI_DIR/php.ini"

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html

# enable .htaccess
RUN echo "<Directory /var/www/html>"             >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Options Indexes FollowSymLinks"    >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    AllowOverride All"                 >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Require all granted"               >> /etc/apache2/sites-available/000-default.conf 
RUN echo "</Directory>"                          >> /etc/apache2/sites-available/000-default.conf 
RUN ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load
RUN a2enmod rewrite


WORKDIR /var/www/html
RUN git clone https://github.com/espocrm/espocrm.git && cd espocrm && git checkout 62d1c0f
COPY mypatch /var/www/html/espocrm
RUN cd espocrm && git apply mypatch
# seperate composer install to make sure them success
RUN cd espocrm && composer install
# seperate npm install to make sure them success
RUN cd espocrm && rm package-lock.json && npm install --no-cache
RUN npm install -g grunt-cli && cd espocrm && grunt

RUN chown -R www-data:www-data /var/www/html

COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]