#!/usr/bin/env bash

set -eEuo pipefail

if [[ -z "${PROG}" ]]; then
    echo "PROG environment variable must be set"
    exit 1
fi


pushd base
docker build --pull --tag php-fuzzing-base .
popd

progtag=$(echo "php-fuzzing-${PROG}" | tr '[:upper:]' '[:lower:]')

pushd $PROG
docker build --tag "${progtag}" .
popd

docker network rm no-internet || true
docker network create --subnet 172.19.0.0/16 no-internet
sudo iptables --insert DOCKER-USER -s 172.19.0.0/16 -j REJECT --reject-with icmp-port-unreachable
sudo iptables --insert DOCKER-USER -s 172.19.0.0/16 -m state --state RELATED,ESTABLISHED -j RETURN

sudo rm -f /dev/shm/webfuzz_cov.txt 2>/dev/null
if [[ -z "${TOOL+x}" ]]; then
    echo "TOOL environment variable not set, running ${progtag}"

    docker run --network no-internet --init --rm -p 3456:80 -it "${progtag}"
else
    tooltag=$(echo "${progtag}-${TOOL}" | tr '[:upper:]' '[:lower:]')

    pushd $TOOL
    docker build --build-arg APP_TAG="${progtag}" --tag "${tooltag}" .
    popd

    docker run --network no-internet --init --rm -p 3456:80 -p 8080:8080 -p 8090:8090 -v $(pwd)/tmp/zap/:/zap/wrk/ -v /dev/shm:/dev/shm -it "${tooltag}"
fi
