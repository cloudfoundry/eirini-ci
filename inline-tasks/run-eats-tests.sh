#!/bin/bash

set -e

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi

readonly WORKSPACE="$(readlink -f eirini)"

if [[ -n "$HELMLESS" ]]; then
  export EIRINI_ADDRESS EIRINI_TLS_SECRET EIRINI_SYSTEM_NS
  EIRINI_ADDRESS="https://$(<kube/external-ip):8085"
  EIRINI_TLS_SECRET="eirini-certs"
  EIRINI_SYSTEM_NS="eirini-core"
fi

INTEGRATION_KUBECONFIG="$(readlink -f "$KUBECONFIG")" "$WORKSPACE"/scripts/run_eats_tests.sh
