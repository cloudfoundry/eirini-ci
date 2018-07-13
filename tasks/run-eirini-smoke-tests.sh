#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

curl "http://opi-$DIRECTOR_NAME.$KUBE_ENDPOINT/apps" --fail
curl "http://registry-$DIRECTOR_NAME.$KUBE_ENDPOINT/v2" --fail
