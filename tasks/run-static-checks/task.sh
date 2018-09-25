#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

GOPATH=$(readlink -f eirini-source)
golangci-lint --version

cd "$GOPATH/src/code.cloudfoundry.org/eirini"
test -f .golangci.yml
golangci-lint run --verbose
