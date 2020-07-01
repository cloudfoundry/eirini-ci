#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini)"
"$WORKSPACE"/scripts/run_unit_tests.sh
