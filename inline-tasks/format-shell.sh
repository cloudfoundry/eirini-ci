#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

pushd ci-resources || exit 1
# shellcheck disable=SC2046
shfmt -i 2 -d -ci -w $(shfmt -f .) >/dev/null

readonly retval="$?"

git diff --color --exit-code
exit $retval
