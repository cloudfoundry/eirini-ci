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

latest_stable_image_sha=$(yq read eirini-release/helm/values.yaml images.api | grep -o "sha256.*")
latest_stable_commit_sha=$(get_image_config eirini/opi "$latest_stable_image_sha" | jq -r '.config.Labels["org.opencontainers.image.revision"]')

git -C eirini checkout "$latest_stable_commit_sha"
git clone eirini eirini-stable
