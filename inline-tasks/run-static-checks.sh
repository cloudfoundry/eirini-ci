#!/bin/sh

set -euo pipefail
IFS=$'\n\t'

golangci-lint version

cd eirini
test -f .golangci.yml
golangci-lint run --verbose
