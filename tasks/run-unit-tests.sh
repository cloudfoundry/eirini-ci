#!/bin/bash

set -e

# shellcheck disable=SC2034
GOPATH=$(readlink -f eirini-source)

readonly WORKSPACE="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini"
cd "$WORKSPACE"
ginkgo -r -keepGoing --skipPackage=launcher,recipe --skip="{SYSTEM}"
