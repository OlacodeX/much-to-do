#!/usr/bin/env bash
set -euo pipefail

ALB_HOST="${1:?Usage: $0 <alb-dns-name> [path]}"
PATH_SUFFIX="${2:-/health}"
URL="http://${ALB_HOST#http://}"
URL="http://${URL#https://}"
URL="http://${URL%%/*}${PATH_SUFFIX}"

echo "Checking ${URL}"
curl -sf --connect-timeout 10 --max-time 15 "$URL"
echo ""
echo "OK"
