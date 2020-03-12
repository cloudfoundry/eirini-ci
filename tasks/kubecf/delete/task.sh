#!/bin/bash

set -xeuo pipefail

helm delete --purge kubecf
kubectl delete namespace kubecf

helm delete --purge cf-operator
kubectl get customresourcedefinitions,validatingwebhookconfigurations,mutatingwebhookconfigurations --output name | xargs kubectl delete
kubectl delete namespace cf-operator
