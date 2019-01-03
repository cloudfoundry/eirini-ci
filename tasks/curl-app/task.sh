#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly public_ip=$(cat worker-info/public-ip)
readonly status_code="$(curl -s -o /dev/null -I -w "%{http_code}" "$public_ip":32016)"

if [ "200" != "$status_code" ]; then
  echo "Expected status code 200, but got $status_code."
  exit 1
fi
