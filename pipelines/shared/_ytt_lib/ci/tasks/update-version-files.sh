#!/bin/bash

set -euo pipefail

update-digest() {
  local image_path image_name
  image_path="$1"
  image_name="$2"

  digest=$(cat "$image_path/digest")
  sed -i -e "s|eirini/${image_name}@sha256:.*$|eirini/${image_name}@${digest}|g" eirini-release/helm/values.yaml
}

strip-signed-off() {
  local repo
  repo="$1"

  grep -v "Signed-off-by" "$repo/.git/commit_message"
}

generate-commit-message() {
  local ref commit_msg commit_msg_path
  commit_msg_path="$1"
  ref=$(cat "./eirini/.git/ref")
  commit_msg=$(strip-signed-off eirini)

  echo -e "Update image versions\n" >"$commit_msg_path/message"
  echo "eirini commit SHA: $ref" >>"$commit_msg_path/message"
  echo "eirini commit message:" >>"$commit_msg_path/message"
  echo -e "$commit_msg\n" >>"$commit_msg_path/message"
}

main() {
  for image in $IMAGES; do
    update-digest "${image}-image" "$image"
  done

  generate-commit-message "$COMMIT_MSG_PATH"

  cp -r "$REPO/." "$REPO_MODIFIED"
}

main
