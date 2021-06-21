#!/bin/bash

set -e

eirini_controller_path="$(readlink -f eirini-controller)"
readonly eirini_controller_path

cp -a "$eirini_controller_path" eirini-controller-built
./eirini-controller-built/deployment/scripts/build.sh
