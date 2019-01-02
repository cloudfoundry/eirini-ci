#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources-branch/scripts/ibmcloud-functions

main() {
  ibmcloud-login
  export-kubeconfig "$CLUSTER_NAME"
  restart-bits
}

restart-bits() {
  kubectl patch deployment bits -p \
    "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"$(date +'%s')\"}}}}}"
}

main
