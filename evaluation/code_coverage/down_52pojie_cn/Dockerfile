FROM php-fuzzing-base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
    # https://www.php.net/manual/en/image.installation.php 
    zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping \
    vim \
    # other packages 
    git wget unzip \
    && rm -rf /var/lib/apt/lists/* 

WORKDIR /app
RUN wget https://github.com/ganlvtech/down_52pojie_cn/releases/download/v2.1.3/dist.zip && unzip dist.zip
RUN cp -r /app/dist/* /var/www/html && cp -r /app/dist/.fancyindex /var/www/html/.fancyindex

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY down.conf /etc/apache2/sites-available
RUN ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/rewrite.load
RUN a2enmod rewrite
RUN a2ensite down.conf
RUN a2dissite 000-default.conf

COPY data /var/www/html/data
COPY config.php /var/www/html/php/config/config.php
COPY start_server.sh /start_server.sh

COPY zap/ /zap_context/
COPY wapiti/ /wapiti_context/

CMD ["bash", "/start_server.sh"]