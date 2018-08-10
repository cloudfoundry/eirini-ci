#!/bin/bash

set -x

pushd capi/src/cloud_controller_ng/ || exit 1
	git pull origin eirini
popd || exit 1

cp -r capi/. capi-modified

pushd capi-modified || exit 1
  git add src/cloud_controller_ng/
  git config --global user.email "eirini@cloudfoundry.org"
  git config --global user.name "Come-On Eirini"
  git commit --all --message "Bump cloud_controller_ng submodule"
popd || exit 1
