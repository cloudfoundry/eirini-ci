#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PROJECT_ROOT

readonly world_name=dhall-ci
readonly target="${1:-eirini}"
readonly private_repo="${2:-$PROJECT_ROOT/../eirini-private-config}"
readonly working_branch=${3:-"master"}
readonly ci_branch=${4:-"master"}
readonly worker_count=${5:-"3"}
readonly storage_class="hostpath"
readonly basedir="$(cd "$(dirname "$0")" && pwd)"
readonly diego_cell_count=3

PIPELINE_YML=$(mktemp)
export PIPELINE_YML

# aviator -f "$basedir"/aviator.yml
dhall-fly <<<"$basedir/pipeline.dhall" >"$PIPELINE_YML"

fly --target "$target" \
  set-pipeline \
  --config "$PIPELINE_YML" \
  --pipeline "$world_name" \
  --var ibmcloud-account=7e51fbb83371a0cb0fd553fab15aebf4 \
  --var ibmcloud-user=eirini@cloudfoundry.org \
  --var ibmcloud-password="$(pass show eirini/ibm-id)" \
  --var world-name="$world_name" \
  --var ci-resources-branch="$ci_branch" \
  --var dockerhub-user=eiriniuser \
  --var dockerhub-password="$(pass eirini/docker-hub)" \
  --var github-private-key="$(pass eirini/github/private-config/ssh-key)" \
  --var eirini-repo-key="$(pass eirini/github/eirini/ssh-key)" \
  --var eirini-release-repo-key="$(pass eirini/github/eirini-release/ssh-key)" \
  --var eirini-release-branch="ci-dhall" \
  --var eirini-branch="$working_branch" \
  --var worker_count="$worker_count" \
  --var storage_class="$storage_class" \
  --var diego-cell-count="$diego_cell_count" \
  --load-vars-from "$private_repo/concourse/common.yml"