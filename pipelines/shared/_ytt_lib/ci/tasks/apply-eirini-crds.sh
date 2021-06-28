#!/bin/bash

set -eu

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

kubectl apply -f "eirini-controller/deployment/helm/templates/core/lrp-crd.yml"
kubectl apply -f "eirini-controller/deployment/helm/templates/core/task-crd.yml"
