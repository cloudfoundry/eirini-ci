#!/bin/bash
set -euxo pipefail

cd eirini/fluentd
bundle
rspec
