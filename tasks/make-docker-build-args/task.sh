#!/bin/bash
set -euo pipefail

revision=$(git -C repository rev-parse HEAD)
echo "{\"GIT_SHA\": \"$revision\"}" >docker-build-args/args.json
