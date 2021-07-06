#!/bin/bash

set -euo pipefail

update-digest() {
  local image_path image_name
  image_path="$1"
  image_name="$2"

  digest=$(cat "$image_path/digest")
  sed -i -e "s|eirini/${image_name}@sha256:.*$|eirini/${image_name}@${digest}|g" eirini-release/helm/values.yaml
}

generate-commit-message() {
  local ref commit_msg
  ref=$(cat "./eirini/.git/ref")
  commit_msg=$(grep -v "Signed-off-by" "eirini/.git/commit_message")

  {
    echo -e "Update image versions\n"
    echo "eirini commit SHA: $ref"
    echo "eirini commit message:"
    echo -e "$commit_msg\n"
  } >"$COMMIT_MSG_PATH/message"

}

main() {
  for image in $IMAGES; do
    update-digest "${image}-image" "$image"
  done

  generate-commit-message

  cp -r "$REPO/." "$REPO_MODIFIED"
}

main
