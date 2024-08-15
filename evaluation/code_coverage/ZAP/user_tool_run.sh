#!/usr/bin/env bash

set -Eeuxo pipefail

if [[ -f /zap_context/manual ]]; then
    echo "This app requires the manual approach, exitting."
    exit 1
fi

Xvfb :1 -screen 0 1024x768x16 -ac -nolisten tcp -nolisten unix &
sleep 1

opt_args=()

if [[ -f /zap_context/ajax ]]; then
    opt_args+=("-j")
fi

if [[ -f /zap_context/user ]]; then
    opt_args+=("-U")
    opt_args+=("user")
fi

./zap-full-scan.py -t $(cat /zap_context/target.txt) \
    ${opt_args[@]} \
    -n /zap_context/ZAP.context \
    -r /tmp/zap_report.html || true
