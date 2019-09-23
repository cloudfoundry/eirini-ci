#!/bin/bash

set -euo pipefail

main() {
  update-digest image1 "$IMAGE1_NAME"

  if [[ -d image2 ]]; then
    update-digest image2 "$IMAGE2_NAME"
  fi

  if [[ -d image3 ]]; then
    update-digest image3 "$IMAGE3_NAME"
  fi

  # shellcheck disable=SC2153
  commit-changes "$COMPONENT_NAME"
}

update-digest() {
  local image_path image_name
  image_path="$1"
  image_name="$2"
  echo -n "$(cat "$image_path/digest")" >eirini-release/helm/eirini/versions/"$image_name"
}

commit-changes() {
  local msg
  component_name="$1"
  msg=$(commit-message "$component_name")
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

strip-signed-off() {
  local repo
  repo="$1"

  grep -v "Signed-off-by" "$repo/.git/commit_message"
}

commit-message() {
  local ref component_name commit_msg
  component_name="$1"
  ref=$(cat ./image-code-repository/.git/ref)
  commit_msg=$(strip-signed-off ./image-code-repository)

  echo -e "Update image versions\n"
  echo "$component_name commit SHA: $ref"
  echo "$component_name commit message:"
  echo -e "$commit_msg\n"
}
