FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
    libcurl4-openssl-dev \
    libxml2-dev \
    libzip-dev \
    libbz2-dev \
    libgmp-dev \
    libonig-dev \
    libc-client-dev libkrb5-dev \
    # maria db \
    mariadb-server mariadb-client \
    # other packages \
    git \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    # && docker-php-ext-install mysqli pdo pdo_mysql ctype curl dom fileinfo filter GD hash JSON libxml mbstring openssl posix session SimpleXML XMLReader XMLWriter zip zlib bz2  intl ldap smbclient ftp imap bcmath gmp exif

RUN docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install gd mysqli pdo pdo_mysql ctype curl posix session \
        zip bz2 intl bcmath gmp exif imap
RUN docker-php-ext-install ftp
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install filter
RUN docker-php-ext-install json
RUN docker-php-ext-install mbstring     

# RUN docker-php-ext-install hash
# RUN php -i && docker-php-ext-install openssl
# RUN docker-php-ext-install libxml
# RUN docker-php-ext-install dom xmlreader xmlwriter
# RUN docker-php-ext-install zlib
# RUN docker-php-ext-install ldap
# RUN docker-php-ext-install smbclient


WORKDIR /app
ADD https://download.nextcloud.com/server/releases/nextcloud-23.0.0.tar.bz2 nextcloud.tar.bz2
ADD https://github.com/nextcloud/mail/archive/refs/tags/v1.13.0.tar.gz mail.tar.gz
RUN tar -xjf nextcloud.tar.bz2
RUN tar -xzf mail.tar.gz
RUN mv nextcloud/* /var/www/html/
RUN mkdir /var/www/html/apps/mail
# RUN mv mail-1.13.0/* /var/www/html/apps/mail
RUN rm nextcloud.tar.bz2 mail.tar.gz
# RUN rm -r nextcloud mail-1.13.0
COPY config.php /var/www/html/config/config.php
RUN mkdir -p /var/www/html/data/ && touch /var/www/html/data/.ocdata
RUN chmod -R 777 /var/www/html

RUN wget https://getcomposer.org/installer -O composer-setup.php
RUN php composer-setup.php

RUN mv mail-1.13.0/* /var/www/html/apps/mail
WORKDIR /var/www/html/apps/mail/
RUN cp composer.json composer.json.bak
RUN jq 'del(."require-dev"."roave/security-advisories")' composer.json.bak > composer.json

RUN chown -R www-data:www-data /var/www/html

COPY start_server.sh /start_server.sh
COPY set_up.py /set_up.py
COPY nextcloud.sql /nextcloud.sql

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]