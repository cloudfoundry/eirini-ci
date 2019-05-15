#!/bin/bash

set -e

pushd eirini-release || exit 1
git submodule update --init --recursive
popd || exit 1

cp -r eirini-release/. eirini-updated/
