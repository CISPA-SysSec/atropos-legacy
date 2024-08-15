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
    git unzip libzip-dev nano \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip bcmath

# ADD https://github.com/slackero/phpwcms/archive/refs/tags/v1.9.34.zip /phpwcms-zip
RUN git clone https://github.com/slackero/phpwcms /var/www/html/phpwcms
WORKDIR /var/www/html/phpwcms
RUN git checkout 32eb55d
# RUN unzip /phpwcms-zip 
WORKDIR /app

# RUN mv phpwcms-1.9.34 /var/www/html/phpwcms
RUN a2enmod rewrite

RUN mkdir -p /var/www/html/filearchive/
RUN mkdir -p /var/www/html/filearchive/can_be_deleted
RUN mkdir -p /var/www/html/upload/
RUN chown -R www-data:www-data /var/www/html/

COPY conf.inc.php /var/www/html/phpwcms/include/config/conf.inc.php
RUN rm -r /var/www/html/phpwcms/setup/

COPY start_server.sh /start_server.sh
COPY set_up.py /set_up.py
COPY init.sql /init.sql

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]
