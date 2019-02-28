#!/bin/bash

set -euo pipefail

pushd capi-release-fork
git submodule update --init --remote src/cloud_controller_ng
if [ -n "$(git status --porcelain)" ]; then
  git config user.name "Come-On Eirini"
  git config user.email "eirini@cloudfoundry.org"
  git commit -am "BOT: Autoupdate cloud_controller_ng"
fi
popd

cp -r capi-release-fork/. updated-capi-release-fork
