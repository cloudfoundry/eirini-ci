#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'
echo "$GCP_SERVICE_ACCOUNT_JSON" >service-account.json
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

export KUBECONFIG=kube/config
gcloud beta container clusters get-credentials "$CLUSTER_NAME" --region europe-west1
