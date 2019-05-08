#!/bin/bash

set -euo pipefail

git clone https://github.com/cloudfoundry-incubator/eirini-release.git
cd eirini-release
git checkout gh-pages-pr
hub pull-request --base gh-pages --no-edit
