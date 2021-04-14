#!/bin/bash

cat >eirini-image-overrides/values.yml <<EOF
#@data/values
---
EOF

# shellcheck disable=SC2016
yq eval 'del(.images.eirini_controller) | del(.images.resource_validator) | .images as $images | {"images": {"eirini": $images}}' \
  eirini-release/helm/values.yaml >>eirini-image-overrides/values.yml
