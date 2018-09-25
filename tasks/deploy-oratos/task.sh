#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions
# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
   ibmcloud-login
   export-kubeconfig "$CLUSTER_NAME"
   start-docker
   generate-secrets
   deploy
}

generate-secrets() {
  pushd oratos/secrets
    ./generate-tls-certs.sh
  popd
}

deploy() {
  pushd oratos
    ./deploy.sh
  popd
}

main
