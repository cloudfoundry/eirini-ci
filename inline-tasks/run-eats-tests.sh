#!/bin/bash

set -e

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi

readonly WORKSPACE="$(readlink -f eirini)"

export EIRINI_ADDRESS EIRINI_TLS_SECRET EIRINI_SYSTEM_NS EIRINI_WORKLOADS_NS
EIRINI_ADDRESS="https://eirini-opi.cf.svc.cluster.local:8085"
EIRINI_TLS_SECRET="eirini-certs"
EIRINI_SYSTEM_NS="cf"
EIRINI_WORKLOADS_NS="eirini"

if [[ -n "$HELMLESS" ]]; then
  EIRINI_ADDRESS="https://eirini-api.eirini-core.svc.cluster.local:8085"
  EIRINI_SYSTEM_NS="eirini-core"
  EIRINI_WORKLOADS_NS="eirini-workloads"
fi

service_name=telepresence-$(tr -dc 'a-z0-9' </dev/urandom | fold -w 8 | head -n 1)

export INTEGRATION_KUBECONFIG
INTEGRATION_KUBECONFIG="$(readlink -f "$KUBECONFIG")"

export TELEPRESENCE_SERVICE_NAME=${service_name}

KUBECONFIG="$PWD"/kube/config telepresence --new-deployment "$service_name" \
  --method vpn-tcp \
  --run "${WORKSPACE}/scripts/run_eats_tests.sh"
