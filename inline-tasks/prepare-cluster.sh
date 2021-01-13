#!/usr/bin/env bash

set -xeuo pipefail
IFS=$'\n\t'

export KUBECONFIG="$PWD/kube/config"

kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
kubectl apply -f ci-resources/k8s-specs/restricted-psp.yaml
helm init --service-account tiller --upgrade

kubectl apply -f ci-resources/k8s-specs/inst-inj-job-net-pol.yml
