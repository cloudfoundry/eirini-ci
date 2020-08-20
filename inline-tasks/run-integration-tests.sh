#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini)"

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi
INTEGRATION_KUBECONFIG="$PWD"/kube/config "$WORKSPACE"/scripts/run_integration_tests.sh --skipPackage eats
