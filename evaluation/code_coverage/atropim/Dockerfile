FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php \
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
    # atropim
    nodejs npm libsodium-dev libzip-dev libmagickwand-dev libmagickcore-dev cron \
    # other packages \
    git wget unzip vim nano \
    && rm -rf /var/lib/apt/lists/* 


WORKDIR /app
RUN apt update -y && apt upgrade -y && apt install lsb-release gnupg software-properties-common -y
RUN wget http://repo.mysql.com/mysql-apt-config_0.8.16-1_all.deb && dpkg -i mysql-apt-config_0.8.16-1_all.deb && cat /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29
RUN apt update -y && apt upgrade -y && apt install mysql-server mysql-client -y

RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql sodium zip exif

RUN pecl install imagick && echo "\nextension=imagick.so" >> /usr/local/etc/php/conf.d/php.ini

WORKDIR /var/www/html
# RUN git clone https://github.com/atrocore/atropim.git
RUN git clone https://github.com/atrocore/skeleton-pim.git . && php composer.phar self-update && php composer.phar update
RUN chown -R www-data:www-data /var/www/html
RUN find . -type d -exec chmod 755 {} + && find . -type f -exec chmod 644 {} +;
RUN find client data custom upload -type d -exec chmod 775 {} + && find client data custom upload -type f -exec chmod 664 {} +

RUN echo "<Directory /var/www/html>"             >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Options Indexes FollowSymLinks"    >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    AllowOverride All"                 >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Require all granted"               >> /etc/apache2/sites-available/000-default.conf 
RUN echo "</Directory>"                          >> /etc/apache2/sites-available/000-default.conf 
RUN ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load

COPY php.ini "$PHP_INI_DIR/php.ini"
COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]
