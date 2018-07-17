#!/bin/bash

set -ex

# Due to issue with the docker version used in this image, it needs to be donwgraded until this issue is resolved (https://github.com/docker/for-linux/issues/219#issuecomment-375199143)
apt remove --yes docker-ce
apt install --yes docker-ce=17.09.1~ce-0~ubuntu

# Start Docker Daemon (and set a trap to stop it once this script is done)
echo 'DOCKER_OPTS="--data-root /scratch/docker --max-concurrent-downloads 10"' > /etc/default/docker
service docker start
service docker status
trap 'service docker stop' EXIT
sleep 10

./eirini-helm-release/kube-release/docker/generate-docker-image.sh "$TAG"

docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASSWORD"
docker push "eirini/opi:$TAG"
docker push "eirini/registry:$TAG"
