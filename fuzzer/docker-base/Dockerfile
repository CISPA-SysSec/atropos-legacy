FROM ubuntu:22.04 AS base

# based on https://github.com/opsxcq/docker-vulnerable-dvwa
LABEL maintainer "emre.gueler@rub.de"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt -y install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install -y php7.4 php7.4-bcmath php7.4-bz2 php7.4-intl php7.4-gd \
    php7.4-mbstring php7.4-mysql php7.4-zip php7.4-common php7.4-pgsql \
    php7.4-dev php7.4-xml php7.4-curl \
    vmtouch wget libsodium-dev gettext libzip-dev curl git unzip python3 && \
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

# build php
FROM base AS phpbuild

RUN apt-get update && apt install -y clang llvm libllvm-11-ocaml-dev libllvm11 llvm-11 llvm-11-dev llvm-11-doc llvm-11-examples llvm-11-runtime clang-11 clang-tools-11 clang-11-doc libclang-common-11-dev libclang-11-dev libclang1-11 clang-format-11 clangd-11 libfuzzer-11-dev lldb-11 lld-11 libc++-11-dev libc++abi-11-dev libomp-11-dev build-essential python3-dev automake cmake git flex bison libglib2.0-dev libpixman-1-dev python3-setuptools libxml2-dev     libcurl4-openssl-dev     libjpeg-dev     libpng-dev     libxpm-dev     libmysqlclient-dev     libpq-dev     libicu-dev     libfreetype6-dev     libldap2-dev     libxslt-dev     libssl-dev     libldb-dev libonig-dev 
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-11 main" | tee -a /etc/apt/sources.list
RUN apt install -y  -y
RUN apt install -y lld-11 llvm-11 llvm-11-dev clang-11 || apt-get install -y lld llvm llvm-dev clang
RUN apt install -y gcc-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-plugin-dev libstdc++-$(gcc --version|head -n1|sed 's/\..*//'|sed 's/.* //')-dev
RUN apt install -y libgtk-3-dev
RUN apt install -y sqlite3 libsqlite3-dev libsodium-dev libzip-dev
RUN apt install -y libgtk-3-dev pax-utils python3-msgpack python3-jinja2 python3-pip
RUN python3 -m pip install anytree rstr stopit

RUN wget https://www.openssl.org/source/openssl-1.1.1i.tar.gz && tar xfv openssl-*.tar.gz
RUN cd openssl-*; ./config; make -j; make install

RUN mkdir /tmp/php-src
COPY ./php-src/ /tmp/php-src
WORKDIR /tmp/php-src
RUN make clean
RUN EXTENSION_DIR=/usr/lib/php/20190902/ ./configure --enable-fpm --libdir=/usr/lib/php/20190902/ --prefix=/usr/local/php --enable-mbstring --with-openssl=/usr/local --with-xmlrpc --enable-soap --with-jpeg --with-mysqli --with-pgsql --with-freetype --with-ldap --enable-intl --with-zlib --with-pdo-mysql --enable-gd --with-sodium --with-gettext --with-curl --enable-exif --enable-mbstring --with-zip --enable-bcmath --enable-intl
RUN make -j

RUN mkdir /php_libs
RUN lddtree -l /tmp/php-src/sapi/cgi/php-cgi
RUN lddtree -l /tmp/php-src/sapi/cgi/php-cgi | xargs -I {} cp --parents {} /php_libs/
RUN ls -lah /php_libs

# build pcov
FROM base AS pcov
RUN mkdir /tmp/pcov
COPY ./pcov/ /tmp/pcov
RUN cd /tmp/pcov && phpize && ./configure --enable-pcov && make -j && make install

# build php-nim
# FROM nimlang/nim as phpnim
# RUN apt update && apt install -y build-essential make gcc
# RUN wget https://musl.libc.org/releases/musl-1.2.4.tar.gz && tar xfv musl*.tar.gz && cd musl-* && ./configure && make -j && make install
# COPY ./fastcgi.nim/ /tmp/fastcgi.nim
# RUN cd /tmp/fastcgi.nim/tests; PATH=/usr/local/musl/bin/:$PATH nim --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static c --d:release --opt:speed php.nim

# continue base, but only copy what is necessary (php and pcov)
FROM base AS base2

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
WORKDIR /

RUN mkdir /atropos

COPY --from=phpbuild /tmp/php-src/sapi/cgi/php-cgi /atropos/target_executable
COPY --from=pcov /usr/lib/php/20190902 /usr/lib/php/20190902
COPY --from=phpbuild /php_libs /php_libs
RUN ls -lah /php_libs/; find /usr/local | wc -l
RUN ls -lah /lib/lsb/init-functions
RUN cd /php_libs; rsync -hvrPt --ignore-existing ./ ..
RUN ls -lah /lib/lsb/init-functions
RUN ls -lah /
RUN find /usr/local | wc -l
# RUN rsync -a /tmp/lib/ /usr/lib; rsync -a /tmp/locallib/ /usr/local/
RUN find / -name libssl.so.1.1
RUN find /php_libs/ -name libssl.so.1.1
# RUN rm -rf /tmp/lib /tmp/locallib
#COPY --from=phpnim /tmp/fastcgi.nim/tests/php /atropos/php-nim

