#!/bin/bash

set -e
readonly WORKSPACE="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini"
cd "$WORKSPACE"
ginkgo -r -keepGoing --skipPackage=launcher,recipe --skip="Desiring some LRPs|Desiretask"
