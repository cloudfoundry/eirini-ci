#!/bin/sh

set -eu

golangci-lint version

cd eirini
test -f .golangci.yml
golangci-lint run --verbose
