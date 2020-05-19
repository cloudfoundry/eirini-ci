#!/bin/bash
set -euxo pipefail

cd eirini-fluentd/fluentd
bundle
rspec
