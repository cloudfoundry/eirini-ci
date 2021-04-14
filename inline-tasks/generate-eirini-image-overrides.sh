#!/bin/bash

cat >eirini-image-overrides/values.yml <<EOF
#@data/values
---
EOF
yq eval 'del(.images.eirini_controller) | del(.images.resource_validator) | .images as $images | {"images": {"eirini": $images}}' \
  eirini-release/helm/values.yaml >>eirini-image-overrides/values.yml
