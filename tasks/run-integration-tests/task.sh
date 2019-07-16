#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini-source)"
INTEGRATION_KUBECONFIG="$PWD"/kube/config "$WORKSPACE"/scripts/run_integration_tests.sh
