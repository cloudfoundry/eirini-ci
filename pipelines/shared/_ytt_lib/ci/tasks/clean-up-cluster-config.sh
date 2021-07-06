#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  remove-cluster-values
  copy-output
}

remove-cluster-values() {
  pushd "$CLUSTER_STATE"
  {
    rm -rf "environments/kube-clusters/$CLUSTER_NAME"
  }
  popd
}

copy-output() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$CLUSTER_DIR"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Delete values file for cluster: $CLUSTER_NAME"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r "$CLUSTER_STATE/." "$CLUSTER_STATE_MODIFIED/"
}

main
