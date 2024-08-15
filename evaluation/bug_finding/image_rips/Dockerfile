FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update
RUN apt-get update && \
    apt -y install software-properties-common && \
    add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install -y php7.4 php7.4-bcmath php7.4-bz2 php7.4-intl php7.4-gd \
    php7.4-mbstring php7.4-mysql php7.4-zip php7.4-common php7.4-pgsql \
    php7.4-dev php7.4-xml php7.4-json php7.4-intl \
    vmtouch wget libsodium-dev gettext libzip-dev curl openssl unzip chromium-browser python3 python3-pip && \
    update-alternatives --set php /usr/bin/php7.4
RUN apt-get install curl -y