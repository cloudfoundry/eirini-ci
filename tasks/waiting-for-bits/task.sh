#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  local -r expected_image_digest="$(<bits-latest/digest)"
  if actual-digest-equals "name=bits" "$expected_image_digest"; then
    echo Expected digest "$expected_image_digest" is running
  else
    echo Expected digest "$expected_image_digest" not running
    exit 1
  fi

  local -r ready=$(is-labeled-container-ready scf "name=bits")
  if [ "$ready" == "true" ]; then
    echo Bits-Service is ready
    exit 0
  else
    echo Bits-Service is NOT ready
    exit 1
  fi
}

actual-digest-equals() {
  local -r label="${1?Label not provided}"
  local -r expected_image_digest="${2?Expected digest not provided}"

  local -r digest_len=${#expected_image_digest}
  local -r running_image_digest="$(running-image-digest "$label" "$digest_len")"

  [ "$expected_image_digest" == "$running_image_digest" ]
}

running-image-digest() {
  local -r label="${1?Label not provided}"
  local -r digest_len="${2?Expected digest length not provided}"

  local -r running_image_id="$(kubectl get pods --selector "$label" --namespace scf --output jsonpath='{.items[].status.containerStatuses[0].imageID}')"

  echo "${running_image_id:(-$digest_len)}"
}

main
