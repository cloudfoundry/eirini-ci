#!/bin/bash

set -ex

readonly HELM_DIR=./eirini-release/kube-release/helm/eirini

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config

cp ./configs/opi.yaml $HELM_DIR/configs/
kubectl config view --flatten > $HELM_DIR/configs/kube.yaml

set +e
helm delete --purge --name "$TAG"
set -e

helm install \
	--set-string "ingress.opi.host=eirini-opi.$KUBE_ENDPOINT" \
	--set-string "ingress.registry.host=eirini-registry.$KUBE_ENDPOINT" \
  --set-string "config.opi_image=eirini/opi:$TAG" \
	--debug \
	--name "$TAG" \
	./eirini-release/kube-release/helm/eirini

