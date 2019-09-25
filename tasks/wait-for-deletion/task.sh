#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
kubectl get namespaces scf
