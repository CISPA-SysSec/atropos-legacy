#!/usr/bin/env bash

set -Eeuxo pipefail

Xvfb :1 -screen 0 1024x768x16 -ac -nolisten tcp -nolisten unix &
sleep 1

./zap-webswing.sh
