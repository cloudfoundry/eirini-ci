#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
if kubectl get namespaces scf; then
  exit 1
fi
