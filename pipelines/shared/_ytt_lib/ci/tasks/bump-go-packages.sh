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

bump-go() {
  local go_version
  go_version="$(jq -r '.env[] | select(test("GOLANG_VERSION"))' golang-image/metadata.json | awk -F '=' '{print $2}')"
  go_minor_version="$(echo "$go_version" | grep -o '[0-9]\+.[0-9]\+')"
  pushd repository
  {
    go mod edit -go="$go_minor_version"
    grep -r -l --exclude-dir=vendor "FROM golang" |
      while IFS= read -r image; do
        sed -i "s/golang:[0-9\.]\+/golang:$go_version/g" "$image"
      done
  }
  popd

}

main() {
  bump-go
  bump
  verify-compilability
  commit
}

main
