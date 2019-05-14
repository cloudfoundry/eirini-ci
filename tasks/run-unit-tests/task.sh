#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini-source)/src/code.cloudfoundry.org/eirini"
"$WORKSPACE"/scripts/run_unit_tests.sh
