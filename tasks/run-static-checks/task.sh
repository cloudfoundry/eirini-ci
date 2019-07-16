#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

golangci-lint --version

cd "eirini-source"
test -f .golangci.yml
golangci-lint run --verbose
