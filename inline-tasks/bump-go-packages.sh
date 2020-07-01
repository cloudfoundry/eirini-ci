#!/usr/bin/env bash

set -euxo pipefail

commit() {
  pushd repository
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add go.mod go.sum vendor/
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "Bump go packages"
  else
    echo "Repo is clean"
  fi
  popd
  cp -r repository/. repository-updated
}

bump() {
  go get github.com/maxbrunsfeld/counterfeiter
  pushd repository
  go get -t -u ./...
  go mod tidy
  go mod vendor
  go generate ./...
  popd
}

verify-compilability() {
  pushd repository
  ginkgo -mod=vendor -dryRun -r
  go build -mod=vendor ./...
  popd
}

main() {
  bump
  verify-compilability
  commit
}

main
