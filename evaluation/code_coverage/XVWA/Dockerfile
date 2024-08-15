FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
    # maria db \
    mariadb-server mariadb-client \
    # other packages \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql

WORKDIR /app
RUN git clone https://github.com/s4n7h0/xvwa.git && \
   cd xvwa && \
   git checkout fb30fa5
RUN cp -r xvwa /var/www/html
COPY config.php /var/www/html/xvwa/config.php
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

RUN mkdir -p /run/mysqld/ && touch /run/mysqld/mysqld.sock && chown mysql:mysql /run/mysqld/mysqld.sock

COPY php.ini "$PHP_INI_DIR/php.ini"

COPY start_server.sh /start_server.sh
COPY set_up.py /set_up.py

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]