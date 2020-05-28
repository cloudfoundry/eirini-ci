#!/usr/bin/env bash

set -xeuo pipefail
IFS=$'\n\t'

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
helm init --service-account tiller --upgrade
