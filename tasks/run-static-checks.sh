#!/bin/bash

set -x -e

GOPATH=$(readlink -f eirini-source)
readonly PROJECT_DIR="$GOPATH/src/code.cloudfoundry.org/eirini"
readonly GOLANGCI_LINT_VERSION="v1.7.2"

main() {
    lint_tool=$(getLintTool)
    cd "$PROJECT_DIR"
    runStaticCodeChecks "$lint_tool"
}

getLintTool() {
    curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh| bash -s "$GOLANGCI_LINT_VERSION"
    readlink -f bin/golangci-lint
}

runStaticCodeChecks() {
    local lint_tool=$1
    test -f .golangci.yml
    $lint_tool run
}

main
