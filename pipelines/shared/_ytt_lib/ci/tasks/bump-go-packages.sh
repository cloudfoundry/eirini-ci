#!/usr/bin/env bash

set -euxo pipefail

modVendor=
if [[ -d "$REPO_PATH/vendor" ]]; then
  modVendor="-mod=vendor"
fi

bump() {
  pushd "$REPO_PATH"
  go get -t -u ./...
  go mod tidy
  if [[ -n "$modVendor" ]]; then
    go mod vendor
  fi
  go generate ./...
  popd
}

verify-compilability() {
  pushd "$REPO_PATH"
  go run github.com/onsi/ginkgo/v2/ginkgo --mod=vendor --dry-run -r
  go build "$modVendor" ./...
  popd
}

bump-go() {
  local go_version
  go_version="$(jq -r '.env[] | select(test("GOLANG_VERSION"))' golang-image/metadata.json | awk -F '=' '{print $2}')"
  go_minor_version="$(echo "$go_version" | grep -o '[0-9]\+.[0-9]\+')"
  pushd "$REPO_PATH"
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

  cp -r "$REPO_PATH"/. "$REPO_UPDATED_PATH"
}

main
