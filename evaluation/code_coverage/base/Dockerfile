FROM php:7-apache-bullseye

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y python3-full python3-pip git unzip \
    && python3 -m venv /venv \
    && /venv/bin/pip install requests beautifulsoup4 \
    && rm -rf /var/lib/apt/lists/*

COPY php.ini ${PHP_INI_DIR}/php.ini

WORKDIR /tmp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer
USER www-data
RUN git clone https://github.com/egueler/php-instrumentor.git && \
    cd php-instrumentor && \
    composer install 
USER root