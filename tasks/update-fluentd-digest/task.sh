#!/bin/bash

set -euxo pipefail

main() {
  update-digest
  commit-changes
}

update-digest() {
  echo -n "$(cat docker-fluentd/digest)" > eirini-release/helm/eirini/versions/fluentd
}

commit-changes() {
  pushd eirini-release
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add helm/eirini/versions/fluentd
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Update fluentd image"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-updated
}

main
