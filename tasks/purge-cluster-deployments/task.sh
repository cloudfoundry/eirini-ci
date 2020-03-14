#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# shellcheck disable=SC1091
source ci-resources/scripts/ibmcloud-functions

# shellcheck disable=SC1091
source ci-resources/scripts/kube-functions

ibmcloud-login

if ! cluster-exists "$CLUSTER_NAME"; then
  echo "WARNING: the cluster $CLUSTER_NAME does not exists."
  echo "WARNING: Ignore this if you are creating the cluster for the first time"
  exit 0
fi

export-kubeconfig "$CLUSTER_NAME"

kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
helm init --service-account tiller --upgrade --wait
kubectl delete ns cf-system || true
kubectl delete ns cf-workloads || true
purge-helm-deployments
