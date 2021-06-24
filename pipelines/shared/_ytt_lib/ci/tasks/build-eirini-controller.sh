#!/bin/bash

set -e

trap "pkill dockerd" EXIT

run_docker_daemon() {
  start-docker &

  echo 'until docker info; do sleep 5; done' >/usr/local/bin/wait_for_docker
  chmod +x /usr/local/bin/wait_for_docker
  timeout 300 wait_for_docker

  docker <<<"$DOCKERHUB_PASS" login --username "$DOCKERHUB_USER" --password-stdin
}

generate_values() {
  local eirini_controller_path values_source_path values_dest_path
  eirini_controller_path="$(readlink -f eirini-controller)"
  values_source_path=$(readlink -f "eirini-controller/deployment/helm/values.yaml")
  values_dest_path=$(readlink -f "state-modified/eirini-controller")

  "$eirini_controller_path"/deployment/scripts/build.sh

  mkdir -p "$values_dest_path"
  cp "$values_source_path" "$values_dest_path"
}

run_docker_daemon
generate_values
