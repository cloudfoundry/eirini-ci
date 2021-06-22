#!/bin/bash

set -e

eirini_controller_built_path="$(readlink -f eirini-controller-built)"
readonly eirini_controller_built_path

trap "pkill dockerd" EXIT

start-docker &

echo 'until docker info; do sleep 5; done' >/usr/local/bin/wait_for_docker
chmod +x /usr/local/bin/wait_for_docker
timeout 300 wait_for_docker

docker <<<"$DOCKERHUB_PASS" login --username "$DOCKERHUB_USER" --password-stdin

"$eirini_controller_built_path"/deployment/scripts/build.sh
