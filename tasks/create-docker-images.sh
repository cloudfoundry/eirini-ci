#!/bin/bash

set -ex

./eirini-release/kube-release/docker/generate-docker-image.sh "$TAG" #TODO: modify script in eirini-release/kube-release/docker to use TAG env variable

docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
docker push "eirini/opi:$TAG"
docker push "eirini/registry:$TAG"
