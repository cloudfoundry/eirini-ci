#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

update-cluster-state-repo() {
  local env_dir
  env_dir="$1"

  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$env_dir/*"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update/add cf-for-k8s values files"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

aggregate-files() {
  local env_dir
  env_dir="cluster-state/$1"

  mkdir -p "$env_dir"
  cp default-values-file/values.yml "$env_dir"/default-values.yml
  cp loadbalancer-values-file/values.yml "$env_dir"/loadbalancer-values.yml
}

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"

aggregate-files "$CLUSTER_DIR"
update-cluster-state-repo "$CLUSTER_DIR"
