#!/bin/bash

set -e

if [[ -n $GOOGLE_APPLICATION_CREDENTIALS ]]; then
  export GOOGLE_APPLICATION_CREDENTIALS
  GOOGLE_APPLICATION_CREDENTIALS=$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")
fi

readonly WORKSPACE="$(readlink -f eirini)"

INTEGRATION_KUBECONFIG="$(readlink -f "$KUBECONFIG")" "$WORKSPACE"/scripts/run_eats_tests.sh
