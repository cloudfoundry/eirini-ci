#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
echo "$GCP_SERVICE_ACCOUNT_JSON" >kube/service-account.json
gcloud auth activate-service-account --key-file="kube/service-account.json"
gcloud config set container/use_application_default_credentials true

export KUBECONFIG=kube/config
gcloud beta container clusters get-credentials "$CLUSTER_NAME" --region europe-west1-b
