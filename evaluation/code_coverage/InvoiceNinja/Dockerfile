FROM ubuntu:22.04

# based on https://github.com/opsxcq/docker-vulnerable-dvwa
LABEL maintainer "emre.gueler@rub.de"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt -y install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install -y php7.4 php7.4-bcmath php7.4-bz2 php7.4-intl php7.4-gd \
    php7.4-mbstring php7.4-mysql php7.4-zip php7.4-common php7.4-pgsql php7.4-curl php7.4-gmp php7.4-soap \
    php7.4-dev php7.4-xml php7.4-json \
    vmtouch wget libsodium-dev gettext libzip-dev curl openssl unzip chromium-browser python3 python3-pip git && \
    update-alternatives --set php /usr/bin/php7.4

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    debconf-utils && \
    echo mariadb-server mysql-server/root_password password vulnerables | debconf-set-selections && \
    echo mariadb-server mysql-server/root_password_again password vulnerables | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    mariadb-server \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# FROM php-fuzzing-base

# # ARG DEBIAN_FRONTEND=noninteractive

# RUN apt-get update -y && \
#     apt-get upgrade -y && \
#     apt-get install -y \
#     # https://www.php.net/manual/en/image.installation.php \
#     zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev iputils-ping libgmp-dev libgmp10 \
#     # maria db \
#     mariadb-server mariadb-client \
#     # libs \
#     libicu-dev libonig-dev libxml2-dev     libcurl4-openssl-dev     libjpeg-dev     libpng-dev     libxpm-dev         libpq-dev     libicu-dev     libfreetype6-dev     libldap2-dev     libxslt-dev     libssl-dev     libldb-dev libonig-dev \
#     # other packages \
#     git unzip libzip-dev \
#     libbz2-dev \
#     && rm -rf /var/lib/apt/lists/*
# #     && docker-php-ext-configure gd --with-jpeg --with-freetype \
# #     && docker-php-ext-install gd mysqli pdo pdo_mysql zip bcmath gmp

# WORKDIR /composer
# RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
# RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# RUN useradd -ms /bin/bash user
# USER user

# WORKDIR /home/user/app
# # RUN curl -o invoiceninja.zip https://download.invoiceninja.com/ninja-v4.5.50.zip && \
# #     unzip invoiceninja.zip && \
# #     rm invoiceninja.zip && \
# #     mv ninja invoiceninja
# RUN git clone https://github.com/invoiceninja/invoiceninja.git
# WORKDIR /home/user/app/invoiceninja
# RUN git checkout v4.5.50
# RUN cp .env.example .env
# RUN git config --global url.https://github.com/.insteadOf git@github.com:
# RUN git clone git@github.com:hillelcoren/l5-google-cloud-storage.git
# RUN composer update
# RUN composer i -o --no-dev

################################################################################

# CMD ["php-fpm"]
# ENTRYPOINT ["docker-entrypoint"]
# VOLUME [/var/www/app/public]
# ENV SELF_UPDATER_SOURCE=
# ENV LOG=errorlog
# ENV IS_DOCKER=true

# ENV BAK_PUBLIC_PATH=/var/www/html/docker-backup-public/
# ENV BAK_STORAGE_PATH=/var/www/html/docker-backup-storage/
# ENV INVOICENINJA_VERSION=4.5.50
# ENV INVOICENINJA_USER=www-data

# RUN php -i && docker-php-ext-install \
#     gd \
#     gmp \
#     opcache \
#     pdo_mysql \
#     zip \
#     bcmath intl gd bz2 \
#     mbstring zip pgsql curl gmp soap \
#     xml json

# RUN docker-php-ext-install bcmath
# RUN docker-php-ext-install ctype
# RUN docker-php-ext-install fileinfo
# RUN docker-php-ext-install gd
# RUN docker-php-ext-install mbstring

# # RUN apt-get update -y && \
# #     apt-get install -y \
# #     libssl-dev

# # RUN docker-php-ext-install openssl
# # RUN docker-php-ext-install PDO
# RUN docker-php-ext-install tokenizer
# RUN docker-php-ext-install xml
# RUN docker-php-ext-install curl
# RUN docker-php-ext-install zip
# RUN docker-php-ext-install gmp
# RUN docker-php-ext-install iconv
# RUN docker-php-ext-install mysqli

# RUN curl -o /tmp/ninja.zip -L https://download.invoiceninja.com/ninja-v4.5.50.zip && \
#     unzip -q /tmp/ninja.zip -d /tmp/ && \
#     mkdir -p /var/www/html && \
#     mv /tmp/ninja/* /var/www/html && \
#     rm -rf /tmp/ninja* && \
#     mv /var/www/html/storage $BAK_STORAGE_PATH && \
#     mv /var/www/html/public $BAK_PUBLIC_PATH && \
#     mkdir -p /var/www/html/public/logo /var/www/html/storage && \
#     chmod -R 755 /var/www/html/storage && \
#     rm -rf /var/www/html/docs /var/www/html/tests

# COPY ninja.tgz /tmp/ninja.tgz
# RUN tar -xzf /tmp/ninja.tgz --directory=/var/www/html/ && \
#     # mkdir -p /var/www/html && \
#     # mv /tmp/ninja/* /var/www/html && \
#     rm -rf /tmp/ninja* && \
#     # mv /var/www/html/storage $BAK_STORAGE_PATH && \
#     # mv /var/www/html/public $BAK_PUBLIC_PATH && \
#     mkdir -p /var/www/html/public/logo /var/www/html/storage && \
#     chmod -R 755 /var/www/html/storage && \
#     rm -rf /var/www/html/docs /var/www/html/tests

COPY ninja_extracted.tar.bz2 /tmp/ninja.tar
RUN mkdir /tmp/ninja 
RUN tar -xvf /tmp/ninja.tar --directory=/tmp/ninja/ 
RUN rm -rf /var/www/html/ 
RUN    mv /tmp/ninja/ninja/ /var/www/html
    # mkdir -p /var/www/html && \
    # mv /tmp/ninja/* /var/www/html && \
RUN rm -rf /tmp/ninja*
    # && \
    # mv /var/www/html/storage $BAK_STORAGE_PATH && \
    # mv /var/www/html/public $BAK_PUBLIC_PATH && \
    # mkdir -p /var/www/html/public/logo /var/www/html/storage && \
    # chmod -R 755 /var/www/html/storage && \
    # rm -rf /var/www/html/docs /var/www/html/tests

WORKDIR /var/www/html/
RUN chown -R www-data:www-data .


# # RUN chmod +x /usr/local/bin/docker-entrypoint
# # COPY rootfs / # buildkit

# ENV INVOICENINJA_USER=www-data
# WORKDIR /var/www/html

# # RUN addgroup --gid=1500 --system "$INVOICENINJA_USER" && \
# #     adduser \
# #         --uid=1500 \
# #         --disabled-password \
# #         --gecos "" \
# #         --home "$(pwd)" \
# #         --ingroup "$INVOICENINJA_USER" \
# #         --no-create-home "$INVOICENINJA_USER" && \
# #     chown -R "$INVOICENINJA_USER":"$INVOICENINJA_USER" .

    # RUN apt-get update && \
    # apt -y install software-properties-common && \
    # add-apt-repository ppa:ondrej/php && \
    # apt update && \
    # vmtouch wget libsodium-dev gettext libzip-dev curl openssl unzip chromium-browser python3 python3-pip && \
    # update-alternatives --set php /usr/bin/php7.4

# # COPY /usr/bin/install-php-extensions /usr/local/bin/
# # RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# # ARG BAK_PUBLIC_PATH
# # ARG BAK_STORAGE_PATH
# # ARG INVOICENINJA_VERSION
# # LABEL maintainer=David Bomba <turbo124@gmail.com>

# # /bin/sh -c #(nop)  CMD ["php-fpm"]
# # /bin/sh -c #(nop)  EXPOSE 9000

# # STOPSIGNAL SIGQUIT

# # # /bin/sh -c set -eux;  cd /usr/local/etc;  if [ -d php-fpm.d ]; then   sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null;   cp php-fpm.d/www.conf.default php-fpm.d/www.conf;  else   mkdir php-fpm.d;   cp php-fpm.conf.default php-fpm.d/www.conf;   {    echo '[global]';    echo 'include=etc/php-fpm.d/*.conf';   } | tee php-fpm.conf;  fi;  {   echo '[global]';   echo 'error_log = /proc/self/fd/2';   echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192';   echo;   echo '[www]';   echo '; if we send this to /proc/self/fd/1, it never appears';   echo 'access.log = /proc/self/fd/2';   echo;   echo 'clear_env = no';   echo;   echo '; Ensure worker stdout and stderr are sent to the main error log.';   echo 'catch_workers_output = yes';   echo 'decorate_workers_output = no';  } | tee php-fpm.d/docker.conf;  {   echo '[global]';   echo 'daemonize = no';   echo;   echo '[www]';   echo 'listen = 9000';  } | tee php-fpm.d/zz-docker.conf

# # # /bin/sh -c #(nop) WORKDIR /var/www/html
# # # /bin/sh -c #(nop)  ENTRYPOINT ["docker-php-entrypoint"]
# # # /bin/sh -c docker-php-ext-enable sodium
# # # /bin/sh -c #(nop) COPY multi:7d7d4b016ee2e2e18720a1a58004eb4d59de798c619f217398cc1066a656bfd0 in /usr/local/bin/

# # RUN set -eux
# # RUN apt-get update
# # RUN apt-get install -y $PHPIZE_DEPS   libargon2-dev   coreutils   libcurl4-openssl-dev   libiconv-hook-dev   libsodium-dev   libxml2-dev   libssl-dev   libreadline-dev   libsqlite3-dev  libonig-dev
# # # TODO
# # # RUN rm -vf /usr/include/iconv.h;  ln -sv /usr/include/gnu-libiconv/*.h /usr/include/

# # ENV CFLAGS="$PHP_CFLAGS"
# # ENV CPPFLAGS="$PHP_CPPFLAGS"
# # ENV LDFLAGS="$PHP_LDFLAGS"  

# # RUN docker-php-source extract
# # WORKDIR /usr/src/php
# # RUN gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"
# # RUN ./configure   --build="$gnuArch"   --with-config-file-path="$PHP_INI_DIR"   --with-config-file-scan-dir="$PHP_INI_DIR/conf.d"     --enable-option-checking=fatal     --with-mhash     --with-pic     --enable-ftp   --enable-mbstring   --enable-mysqlnd   --with-password-argon2   --with-sodium=shared   --with-pdo-sqlite=/usr   --with-sqlite3=/usr     --with-curl   --with-openssl   --with-readline   --with-zlib     --disable-phpdbg     $(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit')     --disable-cgi     --enable-fpm   --with-fpm-user=www-data   --with-fpm-group=www-data --with-iconv   
# # RUN make -j "$(nproc)"
# # RUN find -type f -name '*.a' -delete
# # RUN make install
# # RUN find   /usr/local   -type f   -perm '/0111'   -exec sh -euxc '    strip --strip-all "$@" || :   ' -- '{}' +  
# # RUN make clean
# #  RUN cp -v php.ini-* "$PHP_INI_DIR/"
# #  RUN cd /
# # RUN docker-php-source delete
# #  RUN runDeps="$(   scanelf --needed --nobanner --format '%n#p' --recursive /usr/local    | tr ',' '\n'    | sort -u    | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'  )"

# # RUN apk add --no-cache $runDeps
# #  RUN apk del --no-network .build-deps
# #  RUN pecl update-channels
# # RUN rm -rf /tmp/pear ~/.pearrc
# # RUN php --version

# # /bin/sh -c #(nop) COPY file:ce57c04b70896f77cc11eb2766417d8a1240fcffe5bba92179ec78c458844110 in /usr/local/bin/
# # /bin/sh -c set -eux;   apk add --no-cache --virtual .fetch-deps gnupg;   mkdir -p /usr/src;  cd /usr/src;   curl -fsSL -o php.tar.xz "$PHP_URL";   if [ -n "$PHP_SHA256" ]; then   echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -;  fi;   if [ -n "$PHP_ASC_URL" ]; then   curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL";   export GNUPGHOME="$(mktemp -d)";   for key in $GPG_KEYS; do    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key";   done;   gpg --batch --verify php.tar.xz.asc php.tar.xz;   gpgconf --kill all;   rm -rf "$GNUPGHOME";  fi;   apk del --no-network .fetch-deps
# # /bin/sh -c #(nop)  ENV PHP_SHA256=166eaccde933381da9516a2b70ad0f447d7cec4b603d07b9a916032b215b90cc
# # /bin/sh -c #(nop)  ENV PHP_URL=https://www.php.net/distributions/php-7.3.33.tar.xz PHP_ASC_URL=https://www.php.net/distributions/php-7.3.33.tar.xz.asc
# # /bin/sh -c #(nop)  ENV PHP_VERSION=7.3.33
# # /bin/sh -c #(nop)  ENV GPG_KEYS=CBAF69F173A0FEA4B537F470D66C9593118BCCB6 F38252826ACD957EF380D39F2F7956BC5DA04B5D
# # /bin/sh -c #(nop)  ENV PHP_LDFLAGS=-Wl,-O1 -pie
# # /bin/sh -c #(nop)  ENV PHP_CPPFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
# # /bin/sh -c #(nop)  ENV PHP_CFLAGS=-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64
# # /bin/sh -c set -eux;  mkdir -p "$PHP_INI_DIR/conf.d";  [ ! -d /var/www/html ];  mkdir -p /var/www/html;  chown www-data:www-data /var/www/html;  chmod 777 /var/www/html
# # /bin/sh -c #(nop)  ENV PHP_INI_DIR=/usr/local/etc/php
# # /bin/sh -c set -eux;  adduser -u 82 -D -S -G www-data www-data
# # /bin/sh -c apk add --no-cache   ca-certificates   curl   tar   xz   openssl
# # /bin/sh -c #(nop)  ENV PHPIZE_DEPS=autoconf   dpkg-dev dpkg   file   g++   gcc   libc-dev   make   pkgconf   re2c
# # /bin/sh -c #(nop)  CMD ["/bin/sh"]
# # /bin/sh -c #(nop) ADD file:cf4b631a115c2bbfbd81cad2d3041bceb64a8136aac92ba8a63b6c51d60af764 in /


# USER root

RUN add-apt-repository ppa:mozillateam/ppa

COPY start_server.sh /start_server.sh
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY php.ini /etc/php/7.4/apache2/php.ini
COPY db_dump.sql /db_dump.sql
COPY .env /var/www/html/.env
# COPY start.sh /start.sh
# COPY docker-php-entrypoint /docker-php-entrypoint
# COPY set_up.py /set_up.py
# COPY .env /var/www/html/ninja/.env

COPY zap/ /zap_context/
# COPY zap/ZAP.context /home/zap/.ZAP/contexts/zap_context/ZAP.context
COPY wapiti/ /wapiti_context/

USER root
RUN mkdir /instr; chmod 777 -R /instr
WORKDIR /instr
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer
USER www-data
RUN git clone https://github.com/egueler/php-instrumentor.git && \
    cd php-instrumentor && \
    composer install
RUN ls -lah /instr # 12
USER root

CMD ["bash", "/start_server.sh"]
