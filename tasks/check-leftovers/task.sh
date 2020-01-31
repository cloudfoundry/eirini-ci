#!/bin/bash

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"

readonly NAMESPACE="eirini"

check-leftovers() {
  local resource filter leftovers
  resource="$1"
  filter="$2"

  leftovers=$(kubectl -n $NAMESPACE get "$resource" --no-headers=true | grep --invert-match Terminating | grep --extended-regexp "$filter")
  if [ "$leftovers" != "" ]; then
    echo "There are leftover $resource in the eirini namespace:"
    echo "$leftovers"
    exit 1
  fi
}

check-leftovers "pods"
check-leftovers "secrets" ".+-registry-credentials"
check-leftovers "poddisruptionbudgets"
