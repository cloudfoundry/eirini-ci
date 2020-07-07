#!/bin/bash

set -euo pipefail

get_token() {
  local image=$1

  curl \
    --silent \
    "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io" |
    jq -r '.token'
}

get_digest() {
  local image=$1
  local tag=$2
  local token=$3

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/manifests/$tag" |
    jq -r '.config.digest'
}

get_image_config() {
  local image=$1
  local tag=$2
  local token digest

  token="$(get_token "$image")"
  digest=$(get_digest "$image" "$tag" "$token")

  curl \
    --silent \
    --location \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    --header "Authorization: Bearer $token" \
    "https://registry-1.docker.io/v2/$image/blobs/$digest"
}

image_sha=$(cat "eirini-release/helm/eirini/versions/$VERSION_FILE")
repo_sha=$(get_image_config "$IMAGE_NAME" "$image_sha" | jq -r '.Labels["org.opencontainers.image.revision"]')

git -C repository checkout "$repo_sha"
git clone repository repository-modified
