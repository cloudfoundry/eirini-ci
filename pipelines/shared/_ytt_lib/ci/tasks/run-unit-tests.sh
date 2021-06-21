#!/bin/bash

set -e

WORKSPACE="$(readlink -f ${REPO_PATH})"
readonly WORKSPACE
"$WORKSPACE"/scripts/run_unit_tests.sh
