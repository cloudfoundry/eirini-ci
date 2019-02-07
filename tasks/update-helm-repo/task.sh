#!/bin/bash

set -euox pipefail
IFS=$'\n\t'

VERSION="$(cat release-version/version)"

main(){
  update-helm-index
  commit-helm-index
}

update-helm-index(){
  mkdir output
  cp release-output/* output
  helm repo index output --merge gh-pages/index.yaml --url "https://github.com/cloudfoundry-incubator/eirini-release/releases/download/v$VERSION"
  cp output/index.yaml gh-pages
}

commit-helm-index() {
  pushd gh-pages
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add index.yaml
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Update helm repository index YAML with $VERSION templates"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -R gh-pages gh-pages-updated
}

main
