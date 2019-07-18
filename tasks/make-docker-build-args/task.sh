#!/bin/bash
set -euo pipefail

revision=$(git -C eirini rev-parse HEAD)
echo "{\"GIT_SHA\": \"$revision\"}" > docker-build-args/args.json
