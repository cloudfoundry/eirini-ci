#!/bin/sh

set -eu

cd ci-resources
# shellcheck disable=SC2046
shellcheck $(find . -name "set-pipeline" && find . -name "*.sh" && find scripts/ -type f)
