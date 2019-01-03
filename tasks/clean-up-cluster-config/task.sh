#!/bin/bash

set -xeuo pipefail
IFS=$'\n\t'

readonly CLUSTER_DIR="environments/kube-clusters/$CLUSTER_NAME"

main() {
  remove-scf-values
  copy-output
}

remove-scf-values() {
  pushd cluster-state
  rm -r "$CLUSTER_DIR"
  popd
}

copy-output() {
  pushd cluster-state || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$CLUSTER_DIR"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Delete scf values file for cluster: $CLUSTER_NAME"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r cluster-state/. state-modified/
}

main
