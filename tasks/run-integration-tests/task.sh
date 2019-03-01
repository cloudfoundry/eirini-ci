#!/bin/bash

set -e

# shellcheck disable=SC2034
GOPATH=$(readlink -f eirini-source)

readonly WORKSPACE="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini"
INTEGRATION_KUBECONFIG=kube/config "$WORKSPACE"/scripts/run_integration_tests.sh
