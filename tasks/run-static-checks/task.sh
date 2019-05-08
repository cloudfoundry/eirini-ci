#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

golangci-lint --version

cd "eirini-source/src/code.cloudfoundry.org/eirini"
rm -rf recipe/packs
test -f .golangci.yml
golangci-lint run --verbose
