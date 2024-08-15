FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php 
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
    # IMSL
    nodejs npm \
    # maria db 
    mariadb-server mariadb-client \
    # other packages 
    git wget unzip \
    && rm -rf /var/lib/apt/lists/* 

RUN docker-php-ext-install gd pdo json pdo_mysql mysqli

WORKDIR /app
RUN git clone https://github.com/mamun724682/Inventory-Management-System-Laravel-SPA.git IMSL && cd IMSL && git checkout 6654c11 
# COPY mypatch /app/IMSL/mypatch
# RUN cd /app/IMSL && git apply mypatch
RUN cp -r /app/IMSL/* /var/www/html 


# enable composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

WORKDIR /var/www/html
RUN composer install
COPY .env /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# enable .htaccess
#COPY .htaccess /var/www/html/
COPY laravel.conf /etc/apache2/sites-available
RUN ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load
RUN a2enmod rewrite
RUN a2ensite laravel.conf
RUN a2dissite 000-default.conf

COPY php.ini "$PHP_INI_DIR/php.ini"
COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]