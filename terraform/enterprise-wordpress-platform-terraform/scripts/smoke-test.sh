#!/usr/bin/env bash

set -euo pipefail

URL="${1:?Usage: ./smoke-test.sh <wordpress-url>}"

echo "Checking WordPress endpoint: ${URL}"

HTTP_CODE=$(curl \
  --silent \
  --output /dev/null \
  --write-out "%{http_code}" \
  "${URL}")

echo "HTTP status: ${HTTP_CODE}"

if [[ "${HTTP_CODE}" =~ ^2|^3 ]]; then
  echo "WordPress endpoint is responding."
  exit 0
fi

echo "WordPress endpoint check failed."
exit 1