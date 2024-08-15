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
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip

WORKDIR /var/www/html
RUN wget https://downloads.wordpress.org/plugin/iubenda-cookie-law-solution.3.0.5.zip && unzip iubenda-cookie-law-solution.3.0.5.zip && rm iubenda-cookie-law-solution.3.0.5.zip

RUN mv iubenda-cookie-law-solution/* /var/www/html && \
   rmdir iubenda-cookie-law-solution/ && \
   chown -R www-data:www-data /var/www/html

COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]