#!/bin/bash

mkdir -p ~/.kube
echo "$KUBE_CONF" > ~/.kube/config

helm install \
	--set-string \
	  ingress.opi.host=\"eirini-opi."$KUBE_ENDPOINT"\",ingress.registry.host=\"eirini-registry."$KUBE_ENDPOINT"\" \
	--debug \
	--name \
	./eirini-release/kube-release/helm/eirini
