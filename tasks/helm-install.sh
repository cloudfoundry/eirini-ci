#!/bin/bash

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config

helm install \
	--set-string "ingress.opi.host=eirini-opi.$KUBE_ENDPOINT" \
	--set-string "ingress.registry.host=eirini-registry.$KUBE_ENDPOINT" \
  --set-string "config.opi_image=eirini/opi:$TAG" \
	--debug \
	--name "$TAG" \
	./eirini-release/kube-release/helm/eirini

