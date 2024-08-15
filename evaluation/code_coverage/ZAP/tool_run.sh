#!/usr/bin/env bash

set -Eeuxo pipefail

su zap -c "/user_tool_run.sh"
cp /tmp/zap_report.html /zap/wrk/"zap_${APP_TAG}_$(date +%Y-%m-%d_%H:%M:%S).html"