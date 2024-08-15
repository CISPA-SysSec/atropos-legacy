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
    git curl \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    # Use pdo_sqlite instead of pdo_mysql if you want to use sqlite
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip

WORKDIR /app
RUN git clone https://github.com/maxsite/cms.git && \
    cd cms && \
    git checkout 26da038eccb1cd5360b32c8fe24a809fe8212112
RUN cp -r cms/* /var/www/html && \
    chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

# enable .htaccess
RUN echo "<Directory /var/www/html>"             >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Options Indexes FollowSymLinks"    >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    AllowOverride All"                 >> /etc/apache2/sites-available/000-default.conf 
RUN echo "    Require all granted"               >> /etc/apache2/sites-available/000-default.conf 
RUN echo "</Directory>"                          >> /etc/apache2/sites-available/000-default.conf 
RUN ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load


COPY php.ini "$PHP_INI_DIR/php.ini"
COPY start_server.sh "/start_server.sh"
COPY app_info.json "/app_info.json"

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]