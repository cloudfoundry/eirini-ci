#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

set -x

bump-version() {
  local cluster_name master_api_version
  cluster_name="$1"

  master_api_version="$(ibmcloud ks cluster get --cluster "${cluster_name}" --json | jq --raw-output '.masterKubeVersion' | cut -d _ -f 1)"
  if ! is-latest "${master_api_version}"; then
    echo "Updating Kube master..."
    update-master "$cluster_name"
    wait-until-deployed "$cluster_name"
  fi

  update-workers "$cluster_name"
}

wait-until-deployed() {
  local cluster_name
  cluster_name="$1"

  local counter=0
  while true; do
    current_master_kube_version="$(ibmcloud ks cluster get --cluster "${cluster_name}" --json | jq --raw-output '.masterKubeVersion')"
    if [ "$current_master_kube_version" != "$(get-latest-k8s-version)" ]; then
      echo "----"
      counter=$((counter + 1))
    else
      echo "master updated"
      return 0
    fi

    if [[ $counter -gt 1800 ]]; then
      echo "Timed out. Current master version is ${current_master_kube_version}" >&2
      exit 1
    fi

    sleep 1
  done
}

is-latest() {
  local current_version latest_version
  current_version="$1"

  latest_version=$(get-latest-k8s-version)

  [ "$latest_version" = "$current_version" ]
}

update-master() {
  local cluster_name latest_version
  cluster_name="$1"
  latest_version="$(get-latest-k8s-version)"

  ibmcloud ks cluster update -f --cluster "$cluster_name" --kube-version "$latest_version"
}

get-latest-k8s-version() {
  ibmcloud ks versions --json |
    jq --raw-output '.kubernetes[-1] | "\(.major).\(.minor).\(.patch)"'
}

update-workers() {
  local cluster_name
  cluster_name="$1"

  outdated_workers="$(ibmcloud ks workers --cluster "${cluster_name}" -s --json | jq --raw-output '.[] | select(.kubeVersion != .targetVersion) | .id')"

  IFS=$'\n'
  for worker in $outdated_workers; do
    update-worker "$cluster_name" "$worker"
  done
}

update-worker() {
  local cluster_name worker
  cluster_name="$1"
  worker="$2"

  echo "Updating worker ${worker}"
  ibmcloud ks worker update -f --cluster "$cluster_name" --worker "$worker"
}

# shellcheck source=scripts/ibmcloud-functions
source ci-resources/scripts/ibmcloud-functions

ibmcloud-login
bump-version acceptance
