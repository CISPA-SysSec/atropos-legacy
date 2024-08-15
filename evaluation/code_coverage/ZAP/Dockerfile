ARG APP_TAG
ARG DEBIAN_FRONTEND=noninteractive

FROM owasp/zap2docker-stable:2.13.0 AS zap

FROM ${APP_TAG}

RUN apt-get update && apt-get install -q -y --fix-missing 	make 	automake 	autoconf 	gcc g++ 	openjdk-11-jdk 	wget 	curl 	xmlstarlet 	unzip 	git 	openbox 	xterm 	net-tools 	python3-pip 	python-is-python3 	firefox-esr 	xvfb 	x11vnc && 	rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir --upgrade awscli pip python-owasp-zap-v2.4 pyyaml urllib3

RUN useradd -u 1000 -d /home/zap -m -s /bin/bash zap
RUN echo zap:zap | chpasswd

WORKDIR /zap
COPY --from=zap /zap /zap
RUN chown zap:zap /zap
# COPY /zap .
# COPY /zap/webswing /zap/webswing
# COPY zap* CHANGELOG.md /zap/
# COPY webswing.config /zap/webswing/
# COPY webswing.properties /zap/webswing/
COPY --from=zap /home/zap/ /home/zap/
# RUN mkdir /home/zap/.vnc
# COPY policies /home/zap/.ZAP/policies/
# COPY scripts /home/zap/.ZAP_D/scripts/
# COPY .xinitrc /home/zap/
COPY --from=zap /root/.ZAP/ /root/.ZAP/
# COPY policies /root/.ZAP/policies/

# USER zap

ARG TARGETARCH
ARG APP_TAG
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/zap/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV ZAP_PATH=/zap/zap.sh
ENV IS_CONTAINERIZED=true
ENV HOME=/home/zap/
ENV LC_ALL=C.UTF-8
ENV ZAP_PORT=8080
ENV APP_TAG=${APP_TAG}

RUN echo "zap2docker-stable" > /zap/container && chmod a+x /home/zap/.xinitrc
COPY tool_run.sh /tool_run.sh
COPY user_tool_run.sh /user_tool_run.sh
COPY webswing.sh /webswing.sh
COPY user_webswing.sh /user_webswing.sh
COPY prepare_context_file.py /prepare_context_file.py
HEALTHCHECK CMD curl --silent --output /dev/null --fail http://localhost:$ZAP_PORT/ || exit 1 "0s" "0s" "0s" '\x00'