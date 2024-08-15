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
    git unzip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip

WORKDIR /app
RUN git clone https://github.com/digininja/DVWA.git && \
   cd DVWA && \
   git checkout 423ac71
WORKDIR /app/DVWA

RUN cp -r . /var/www/html && \
    mkdir -p /var/www/html/config/ && \
    cp ./config/config.inc.php.dist /var/www/html/config/config.inc.php && \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

COPY php.ini "$PHP_INI_DIR/php.ini"

COPY start_server.sh /start_server.sh
COPY set_up.py /set_up.py
COPY app_info.json /app_info.json

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]