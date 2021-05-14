#!/bin/bash

set -eu

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

kubectl apply -f eirini-release/helm/templates/core/lrp-crd.yml
kubectl apply -f eirini-release/helm/templates/core/task-crd.yml
