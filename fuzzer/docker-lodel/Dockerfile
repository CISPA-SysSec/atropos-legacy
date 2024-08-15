FROM webapp-base

COPY php.ini /etc/php/7.4/apache2/php.ini
WORKDIR /tmp
RUN git clone https://github.com/OpenEdition/lodel.git && cd lodel && git checkout 461ea0c929e1367a6758eb6ea3710e45323ba7bc
RUN (cp -r lodel/* lodel/.* /var/www/html || true) && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf lodel/
COPY lodelconfig.php /var/www/html
WORKDIR /var/www/html
RUN touch 03dde1bd-c6b6-4424-8618-c4488e30484a
RUN cd lodel/scripts && composer install

COPY browser_data.php /var/www/html/
COPY 000-default.conf /etc/apache2/sites-enabled/

RUN chown www-data:www-data -R /var/www/html && \
    rm /var/www/html/index.html

COPY copy_html.sh /
RUN chmod +x /copy_html.sh

RUN service mariadb start && \
    sleep 3 && \
    mysql -uroot -pvulnerables -e "CREATE USER app@localhost IDENTIFIED BY 'vulnerables';CREATE DATABASE dvwa;GRANT ALL privileges ON dvwa.* TO 'app'@localhost;"

EXPOSE 80

COPY main.sh /
ENTRYPOINT ["/bin/bash"]
