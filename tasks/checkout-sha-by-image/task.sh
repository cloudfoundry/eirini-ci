#!/bin/bash

set -euo pipefail

image_sha=$(cat "eirini-release/helm/eirini/versions/$VERSION_FILE")
buildah pull "$IMAGE_NAME@$image_sha"

repo_sha=$(buildah inspect "$IMAGE_NAME@$image_sha" | jq -r '.Docker.config.Labels["org.opencontainers.image.revision"]')
git -C repository checkout "$repo_sha"

git clone repository repository-modified
