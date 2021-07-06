#!/usr/bin/env bash

set -euxo pipefail

yarnpkg upgrade --cwd "$REPO/web"
cp -r "$REPO/." "$REPO_MODIFIED"
