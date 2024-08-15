FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping libzip-dev \
    # maria db \
    mariadb-server mariadb-client \
    # other packages \
    git wget unzip \
    && rm -rf /var/lib/apt/lists/* 

    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
RUN  docker-php-ext-configure gd --with-jpeg --with-freetype && docker-php-ext-install gd pdo pdo_mysql mysqli zip 
    # mbstring curl mysqlnd zip simplexml

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

WORKDIR /app
RUN git clone https://github.com/OpenEdition/lodel.git && cd lodel && git checkout 461ea0c929e1367a6758eb6ea3710e45323ba7bc
RUN (cp -r lodel/* lodel/.* /var/www/html || true) && \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html
COPY lodelconfig.php /var/www/html/lodelconfig.php 
RUN chown -R www-data:www-data /var/www/html
RUN touch 03dde1bd-c6b6-4424-8618-c4488e30484a
RUN cd lodel/scripts && composer install

COPY php.ini "$PHP_INI_DIR/php.ini"
COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]