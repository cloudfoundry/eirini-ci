#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
gcloud auth activate-service-account --key-file="$PWD/service-account.json"

export KUBECONFIG=kube/config
gcloud beta container clusters get-credentials "$CLUSTER_NAME" --region europe-west1
