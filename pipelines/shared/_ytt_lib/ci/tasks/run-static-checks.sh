#!/bin/sh

set -eu

golangci-lint version

cd ${REPO_PATH}
test -f .golangci.yml
golangci-lint run --verbose
