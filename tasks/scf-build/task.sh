#!/bin/bash

set -xeuo pipefail

# shellcheck disable=SC1091
source ci-resources/scripts/docker

main() {
  start-docker
  build-tools
  prepare-release
  make-scf
  update-helm-templates
  docker-push
  git-commit
}

build-tools() {
  export FISSILE_BINARY=/usr/bin/fissile
  export SCF_BIN_DIR=/usr/bin/
  pushd scf
  ./bin/dev/install_tools.sh
  popd
}

prepare-release() {
  pushd scf
  # shellcheck disable=SC1091
  source .envrc
  export FISSILE_STEMCELL=splatform/fissile-stemcell-opensuse:42.3-24.g63783b3-30.60
  make docker-deps
  popd
}

make-scf() {
  pushd scf
  export RUBY_VERSION=2.3.1
  if [[ ! -z "$HELM_CHART_VERSION" ]]; then
    export GIT_TAG="$HELM_CHART_VERSION"
  fi
  make releases \
    compile \
    images
  popd
}

update-helm-templates() {
  rm -rf eirini-release/helm/cf/templates
  rm scf/output/helm/templates/autoscaler-*
  cp -r scf/output/helm/templates eirini-release/helm/cf/
  cp -r scf/output/helm/*.yaml eirini-release/helm/cf/
}

docker-push() {
  docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
  echo "Pushing Docker images ..."
  docker images --format "{{.Repository}}:{{.Tag}}" | grep eirinicf | while read -r DOCKER_IMAGE_AND_TAG; do
    docker push "$DOCKER_IMAGE_AND_TAG"
  done
}

git-commit() {
  pushd eirini-release || exit
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "helm/cf/templates"
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "update scf templates"
  else
    echo "Repo is clean"
  fi
  popd || exit

  cp -r eirini-release/. eirini-release-modified/
}

main
