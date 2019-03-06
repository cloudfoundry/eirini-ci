#!/bin/bash
set -euo pipefail

helm upgrade postfacto-dbs ./ --install --namespace postfacto-dbs
