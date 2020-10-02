#!/bin/bash

set -euo pipefail

update-digest() {
  local image_path image_name
  image_path="$1"
  image_name="$2"
  echo -n "$(cat "$image_path/digest")" >eirini-release/helm/eirini/versions/"$image_name"
}

update-deployment-manifest() {
  local image_path image_name image_digest
  image_path="$1"
  image_name="$2"
  image_digest="$(cat "$image_path/digest")"

  find eirini-release/deploy -type f -exec sed -i -e "s|image: eirini/${image_name}.*$|image: eirini/${image_name}@${image_digest}|g" {} +
}

commit-changes() {
  local msg component repo
  component="$1"
  repo="$2"
  msg=$(commit-message "$component" "$repo")
  pushd eirini-release || exit
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
  local ref component commit_msg repo
  component="$1"
  repo="$2"
  ref=$(cat "./$repo/.git/ref")
  commit_msg=$(strip-signed-off "$repo")

  echo -e "Update image versions\n"
  echo "$component commit SHA: $ref"
  echo "$component commit message:"
  echo -e "$commit_msg\n"
}

for image in $IMAGES; do
  update-digest "docker-${image}" "$image"
  update-deployment-manifest "docker-${image}" "$image"
done

commit-changes "$COMPONENT_NAME" "$COMPONENT_REPO"
