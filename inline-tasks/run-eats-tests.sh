#!/bin/bash

set -e

GOOGLE_APPLICATION_CREDENTIALS="$(readlink -f "$GOOGLE_APPLICATION_CREDENTIALS")"

readonly WORKSPACE="$(readlink -f eirini)"

INTEGRATION_KUBECONFIG="$(readlink -f "$KUBECONFIG")" "$WORKSPACE"/scripts/run_eats_tests.sh
