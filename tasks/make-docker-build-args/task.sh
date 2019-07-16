#!/bin/bash
set -euo pipefail

revision=$(cat eirini/.git/ref)
echo "{\"GIT_SHA\": \"$revision\"}" > docker-build-args/args.json
