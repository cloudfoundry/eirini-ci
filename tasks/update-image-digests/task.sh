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
  local msg
  msg=$(commit-message)
  pushd eirini-release
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add helm/eirini/versions/
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "$msg"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-updated
}

commit-message() {
  local eirini_ref opi_init_ref secret_smuggler_ref fluentd_ref
  eirini_ref=$(cat ./eirini/.git/ref)
  opi_init_ref=$(cat ./eirini-opi-init/.git/ref)
  secret_smuggler_ref=$(cat ./eirini-secret-smuggler/.git/ref)
  fluentd_ref=$(cat ./eirini-fluentd/.git/ref)

  echo -e "Update image versions\n"

  for f in $(git -C eirini-release diff --name-only); do
    case $f in
      "helm/eirini/versions/opi-init")
        echo "OPI init commit SHA: $opi_init_ref"
        ;;
      "helm/eirini/versions/secret-smuggler")
        echo "Secret smuggler commit SHA: $secret_smuggler_ref"
        ;;
      "helm/eirini/versions/fluentd")
        echo "Fluentd commit SHA: $fluentd_ref"
        ;;
      "helm/eirini/versions/opi")
        echo "Eirini commit SHA: $eirini_ref"
        ;;
    esac
  done
}

main
