#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini)"

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi

service_name=telepresence-$(tr -dc 'a-z0-9' </dev/urandom | fold -w 8 | head -n 1)

export INTEGRATION_KUBECONFIG=${PWD}/kube/config
export TELEPRESENCE_EXPOSE_PORT_START=10000
export TELEPRESENCE_SERVICE_NAME=${service_name}
export NODES=8

KUBECONFIG="$PWD"/kube/config telepresence --new-deployment "$service_name" \
  --method vpn-tcp \
  --expose 10000 \
  --expose 10001 \
  --expose 10002 \
  --expose 10003 \
  --expose 10004 \
  --expose 10005 \
  --expose 10006 \
  --expose 10007 \
  --run "${WORKSPACE}/scripts/run_integration_tests.sh"
