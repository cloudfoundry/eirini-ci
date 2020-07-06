#!/bin/bash

set -euo pipefail

export GOPATH="$PWD"

mkdir -p src/code.cloudfoundry.org
cp -r eirinifs src/code.cloudfoundry.org/
cd src/code.cloudfoundry.org/eirinifs
ginkgo -v launchcmd
