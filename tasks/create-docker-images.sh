#!/bin/bash

set -ex

# Start Docker Daemon (and set a trap to stop it once this script is done)
echo 'DOCKER_OPTS="--data-root /scratch/docker --max-concurrent-downloads 10"' > /etc/default/docker
service docker start
service docker status
trap 'service docker stop' EXIT
sleep 10

./eirini-release/kube-release/docker/generate-docker-image.sh "$TAG"

docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"
docker push "eirini/opi:$TAG"
docker push "eirini/registry:$TAG"
