#!/bin/bash

set -euxo pipefail

readonly IMAGES=("opi" "opi-init" "secret-smuggler" "bits-waiter" "rootfs-patcher" "fluentd")

main() {
  for image in "${IMAGES[@]}"; do
    update-digest "$image"
  done
  commit-changes
}

update-digest() {
  local image_name
  image_name="$1"
  echo -n "$(cat "docker-$image_name/digest")" >eirini-release/helm/eirini/versions/"$image_name"
}

commit-changes() {
  pushd eirini-release
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add helm/eirini/versions/
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Update image versions"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-updated
}

main
