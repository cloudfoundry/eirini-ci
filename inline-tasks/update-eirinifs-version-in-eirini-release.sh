#!/bin/bash

set -euo pipefail

eirinifs_version=$(cat eirinifs-release/tag)

pushd eirini-release || exit 1
{
  sed -i "s|  rootfs_version:.*|  rootfs_version: '${eirinifs_version}'|" helm/cf/values.yaml
  git add "helm/cf/values.yaml"
  git config --global user.email "eirini@cloudfoundry.org"
  git config --global user.name "Come-On Eirini"
  git commit --all --message "update eirinifs version"
}
popd || exit 1

cp -r eirini-release/. eirini-release-modified/
