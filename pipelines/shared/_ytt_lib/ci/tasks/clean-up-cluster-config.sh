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
  cp -r "$CLUSTER_STATE/." "$CLUSTER_STATE_MODIFIED/"
}

main
