#!/bin/bash

set -euo pipefail

image=docker.io/eirini/opi
image_sha=$(cat eirini-release/helm/eirini/versions/opi)
buildah pull "$image@$image_sha"

eirini_sha=$(buildah inspect "$image@$image_sha" | jq -r '.Docker.config.Labels["org.opencontainers.image.revision"]')
git -C eirini checkout "$eirini_sha"

git clone eirini eirini-modified
