#!/bin/bash

set -e

WORKSPACE="$(readlink -f eirini)"
readonly WORKSPACE
"$WORKSPACE"/scripts/run_unit_tests.sh
