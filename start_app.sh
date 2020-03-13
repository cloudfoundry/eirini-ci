#!/usr/bin/env bash

script_dir="$(cd "$(dirname "$0")" && pwd)"
TESTS=/home/schaefm/Eirini/cf-acceptance-tests/assets

cd "$TESTS"
apps="dora
golang
java
staticfile
ruby_simple"
echo "$apps" | xargs -n 1 -P 5 $script_dir/scale.sh
