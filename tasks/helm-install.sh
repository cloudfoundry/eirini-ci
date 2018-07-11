#!/bin/bash

set -ex

readonly HELM_DIR=./eirini-release/kube-release/helm/eirini

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config

cp ./configs/opi.yaml $HELM_DIR/configs/
kubectl config view --flatten > $HELM_DIR/configs/kube.yaml

if helm history "$TAG"; then
  helm upgrade \
    "$TAG" \
    ./eirini-release/kube-release/helm/eirini \
    --set-string "ingress.opi.host=eirini-opi.$KUBE_ENDPOINT" \
    --set-string "config.opi_image=eirini/opi:$TAG" \
    --set-string "ingress.registry.host=eirini-registry.$KUBE_ENDPOINT"
else
  helm install \
    ./eirini-release/kube-release/helm/eirini \
    --namespace "$KUBE_NAMESPACE" \
    --set-string "ingress.opi.host=eirini-opi.$KUBE_ENDPOINT" \
    --set-string "ingress.registry.host=eirini-registry.$KUBE_ENDPOINT" \
    --set-string "config.opi_image=eirini/opi:$TAG" \
    --debug \
    --name "$TAG"
fi
