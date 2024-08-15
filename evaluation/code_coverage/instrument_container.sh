#!/bin/bash

set -x

docker stop webapp
docker rm webapp
docker stop webapp_instr
docker rm webapp_instr
cp -p webfuzz_instrumentor.sh /dev/shm/
docker load -i $1 
docker run  -itd -v /dev/shm:/dev/shm --name=webapp_instr webapp-snapshot 
docker exec -t webapp_instr bash -ic "mv /var/www/html /var/www/html_orig; mv /var/www/html_instrumented /var/www/html"
#docker exec -t webapp_instr bash -ic "/dev/shm/webfuzz_instrumentor.sh"
docker commit webapp_instr webapp-snapshot
docker save webapp-snapshot > webapp-snapshot-instrumented.tar

docker stop webapp-snapshot
docker rm webapp-snapshot
docker build --tag=webapp-snapshot docker-flat/ || exit 1
docker save webapp-snapshot > webapp-snapshot-instrumented.tar

set +x
