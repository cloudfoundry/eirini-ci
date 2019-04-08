#!/bin/bash
set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
YELLOW='\033[0;93m'
NOCOLOR='\033[0m'

helm init --client-only >/dev/null
pushd eirini-release/helm/cf || exit
helm dep update
popd || exit

exit_code=0
for filename in ci-resources/sample-configs/*; do
  if helm lint ./eirini-release/helm/cf --values "$filename"; then
    echo -e "${GREEN} PASS - ${YELLOW} $(basename "$filename") ${NOCOLOR}"
  else
    echo -e "${RED} FAIL - ${LIGHT_RED} $(basename "$filename") ${NOCOLOR}"
    exit_code=1
  fi
done

exit $exit_code
