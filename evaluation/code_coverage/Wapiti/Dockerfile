ARG APP_TAG
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=en_US.UTF-8

FROM ${APP_TAG}

RUN apt-get update && apt-get install -q -y --fix-missing 	make 	automake 	autoconf 	gcc g++ 	openjdk-11-jdk 	wget 	curl 	xmlstarlet 	unzip 	git 	openbox 	xterm 	net-tools 	python3-pip 	python-is-python3 	firefox-esr 	xvfb 	x11vnc && 	rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --upgrade awscli pip python-owasp-zap-v2.4 pyyaml urllib3

RUN useradd -u 1000 -d /home/wapiti -m -s /bin/bash wapiti
RUN echo wapiti:wapiti | chpasswd

WORKDIR /usr/src/app

RUN apt update \
  && apt install python3 python3-pip python3-setuptools ca-certificates -y \
  && apt clean -yq \
  && apt autoremove -yq \
  && rm -rf /var/lib/apt/lists/* /tmp/*.tar* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN git clone https://github.com/wapiti-scanner/wapiti.git .

RUN pip3 install .
RUN pip3 install humanize sslyze

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

RUN wapiti --update

COPY tool_run.sh /tool_run.sh
COPY wapiti_endpoint.sh /wapiti_endpoint.sh

ARG APP_TAG
ENV APP_TAG=${APP_TAG}

# COPY --from=build /usr/local/lib/python3.9/dist-packages/ /usr/local/lib/python3.9/dist-packages/
# COPY --from=build /usr/local/bin/wapiti /usr/local/bin/wapiti-getcookie /usr/local/bin/

# RUN chown wapiti:wapiti /wapiti
