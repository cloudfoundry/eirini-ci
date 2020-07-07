#!/bin/bash

set -euo pipefail

get_token() {
  local image=$1

  curl \
    --silent \
    "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io" |
    jq -r '.token'
}

get_image_config() {
  local image=$1
  local digest=$2
  local token=$(get_token $image)

  curl \
    --silent \
    --location \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/blobs/$digest"
}

image_sha=$(cat "eirini-release/helm/eirini/versions/$VERSION_FILE")
repo_sha=$(get_image_config "$IMAGE_NAME" "$image_sha" | jq -r '.Labels["org.opencontainers.image.revision"]')

git -C repository checkout "$repo_sha"
git clone repository repository-modified
