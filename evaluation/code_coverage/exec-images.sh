#!/usr/bin/env bash

set -eEuo pipefail

if [[ -z "${PROG}" ]]; then
    echo "PROG environment variable must be set"
    exit 1
fi

progtag=$(echo "php-fuzzing-${PROG}" | tr '[:upper:]' '[:lower:]')

if [[ -z "${TOOL+x}" ]]; then
    tag=${progtag}
else
    tooltag=$(echo "${progtag}-${TOOL}" | tr '[:upper:]' '[:lower:]')
    tag=${tooltag}
fi
cp list_php_files.php /dev/shm/
docker exec $(docker container ls --all --filter=ancestor="${tag}" --format "{{.ID}}") bash -c "mkdir /var/instr && chmod o+rwx /var/instr; cp /dev/shm/list_php_files.php /var/www/html/;  chown www-data:www-data /var/www/html/list_php_files.php; chmod 777 /var/www/html/list_php_files.php"
docker exec -it $(docker container ls --all --filter=ancestor="${tag}" --format "{{.ID}}") bash
