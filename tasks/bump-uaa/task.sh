#!/bin/bash

set -euo pipefail

git-commit() {
  pushd eirini-release || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "helm/uaa"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update uaa helm chart"
  else
    echo "Repo is clean"
  fi
  popd || exit
}

mkdir -p scf-release-unzipped
unzip scf-release/scf-*.zip -d scf-release-unzipped

rm -rf eirini-release/helm/uaa
cp -r scf-release-unzipped/helm/uaa eirini-release/helm/uaa

git-commit

cp -r eirini-release/. eirini-release-updated/
