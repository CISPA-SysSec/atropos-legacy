#!/usr/bin/env bash

set -eExuo pipefail

if [ ! -f /wapiti_context/args ]; then
    echo "File /wapiti_context/args not found."
    exit 1
fi

# Wait for endpoint to start
while ! curl --output /dev/null --silent --head --fail http://localhost; do
    sleep 0.1 && echo -n .
done

chmod 777 -R /zap
chmod 777 -R /tmp

python3 /webfuzz.py