FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping unzip libzip-dev \
    # maria db \
    mariadb-server mariadb-client \
    # other packages \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip

WORKDIR /app
RUN git clone https://github.com/lmoroz/bWAPP && \
   cd bWAPP && \
   git checkout f3f423c
WORKDIR /app/bWAPP/bWAPP

RUN cp -r . /var/www/html
COPY settings.php /var/www/html/admin/settings.php
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 777 /var/www/html/passwords && \
    chmod -R 777 /var/www/html/images && \
    chmod -R 777 /var/www/html/documents

WORKDIR /var/www/html

COPY start_server.sh /start_server.sh
COPY set_up.py /set_up.py

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]