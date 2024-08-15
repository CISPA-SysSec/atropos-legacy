ARG APP_TAG
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=en_US.UTF-8

FROM ${APP_TAG}

RUN apt-get update && apt-get install -q -y --fix-missing 	make 	automake 	autoconf 	gcc g++ 	openjdk-11-jdk 	wget 	curl 	xmlstarlet 	unzip 	git 	openbox 	xterm 	net-tools 	python3-pip 	python-is-python3 	firefox-esr 	xvfb 	x11vnc && 	rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --upgrade awscli pip python-owasp-zap-v2.4 pyyaml urllib3

RUN useradd -u 1000 -d /home/webfuzz -m -s /bin/bash webfuzz
RUN echo webfuzz:webfuzz | chpasswd

WORKDIR /usr/src/app

RUN apt update \
  && apt install python3 python3-pip python3-setuptools ca-certificates libcurl4-openssl-dev libssl-dev -y \
  && apt clean -yq \
  && apt autoremove -yq \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

ARG firefox_ver=105.0
ARG geckodriver_ver=0.31.0
ARG build_rev=0

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH=$PATH:/opt/firefox

RUN apt update \
  && apt install python3 python3-setuptools curl bzip2 dnsmasq -y \
  && apt-get install -y --no-install-recommends --no-install-suggests \
    `apt-cache depends firefox-esr | awk '/Depends:/{print$2}'` \
     # additional 'firefox-esl' dependencies which is not in 'depends' list
     libasound2 libxt6 libxtst6 \
  && curl -fL -o /tmp/firefox.tar.bz2 \
     https://ftp.mozilla.org/pub/firefox/releases/${firefox_ver}/linux-x86_64/en-GB/firefox-${firefox_ver}.tar.bz2 \
  && tar -xjf /tmp/firefox.tar.bz2 -C /tmp/ \
  && mv /tmp/firefox /opt/firefox \
  # Download and install geckodriver
  && curl -fL -o /tmp/geckodriver.tar.gz \
     https://github.com/mozilla/geckodriver/releases/download/v${geckodriver_ver}/geckodriver-v${geckodriver_ver}-linux64.tar.gz \
  && tar -xzf /tmp/geckodriver.tar.gz -C /tmp/ \
  && chmod +x /tmp/geckodriver \
  && mv /tmp/geckodriver /usr/local/bin/ \
  && apt clean -yq \
  && apt autoremove -yq \
  && rm -rf /var/lib/apt/lists/* /tmp/*.tar* /var/tmp/* \
  && truncate -s 0 /var/log/*log

COPY tool_run.sh /tool_run.sh

COPY webFuzz /var/www/webfuzz-fuzzer
RUN cd /var/www/webfuzz-fuzzer && python3 -m pip install --upgrade -r webFuzz/requirements.txt

RUN apt update && apt-get install -y chromium libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libglib2.0-0 libnspr4 libpango-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxtst6 ca-certificates libnss3 lsb-release xdg-utils wget firefox-esr

RUN mkdir /var/instr && chmod -R 777 /var/instr/
WORKDIR /var/www/
# RUN pip3 install --upgrade -r webfuzz-fuzzer/webFuzz/requirements.txt
# RUN wget https://getcomposer.org/installer -O composer-setup.php
# RUN php composer-setup.php
# RUN rm composer-setup.php
# RUN cd webfuzz-fuzzer/instrumentor/php/ && php /var/www/composer.phar update && php /var/www/composer.phar install
# RUN cd webfuzz-fuzzer/instrumentor/php/ && php src/instrumentor.php --verbose --method file --policy edge --dir /var/www/html/
# RUN mv /var/www/html /var/www/html_uninstrumented && mv /var/www/html_instrumented /var/www/html
COPY cookies.php /var/www/html/
COPY webfuzz.py /
RUN chmod +x /webfuzz.py

ARG APP_TAG
ENV APP_TAG=${APP_TAG}

# COPY --from=build /usr/local/lib/python3.9/dist-packages/ /usr/local/lib/python3.9/dist-packages/
# COPY --from=build /usr/local/bin/wfuzz /usr/local/bin/wfuzz-getcookie /usr/local/bin/

# RUN chown wfuzz:wfuzz /wfuzz
