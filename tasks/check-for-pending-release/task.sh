#!/bin/bash

set -euo pipefail

cd gh-pages-pr
open_prs="$(hub pr list --base gh-pages)"
if [[ ! -z "$open_prs" ]]; then
  echo "Please close the following PRs befoure trying to create a new release:"
  echo "$open_prs"
  exit 1
fi
