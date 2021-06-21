#!/bin/bash

set -eu

export KUBECONFIG="$PWD/kube/config"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"

kubectl apply -f "$CRDS_REPO/$CRDS_PATH/lrp-crd.yml"
kubectl apply -f "$CRDS_REPO/$CRDS_PATH/task-crd.yml"
