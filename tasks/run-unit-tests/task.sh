#!/bin/bash

set -e

readonly WORKSPACE="$(readlink -f eirini-source)"
"$WORKSPACE"/scripts/run_unit_tests.sh
