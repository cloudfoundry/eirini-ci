#!/bin/bash

set -euo pipefail

cflinuxfs3_version=$(cat cflinuxfs3-release/tag)

pushd eirinifs || exit 1
{
  sed -i "s|ARG baseimage=cloudfoundry.*|ARG baseimage=cloudfoundry/cflinuxfs3:${cflinuxfs3_version}|" image/Dockerfile
  git add "image/Dockerfile"
  git config --global user.email "eirini@cloudfoundry.org"
  git config --global user.name "Come-On Eirini"
  git commit --all --message "update cflinuxfs3 version to ${cflinuxfs3_version}"
}
popd || exit 1

cp -r eirinifs/. eirinifs-modified/
