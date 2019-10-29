#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

if [[ "$#" -lt 1 ]]; then
  echo "Usage $0 <world_name> [<target>] [<private_repo>] [working_branch] [ci_branch] [worker_count] [enable_opi_staging]" >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export PROJECT_ROOT

readonly world_name=$1
readonly target="${2:-eirini}"
readonly private_repo="${3:-$PROJECT_ROOT/../eirini-private-config}"
readonly eirini_branch=${4:-"master"}
readonly eirini_release_branch=${5:-"develop"}
readonly ci_branch=${6:-"master"}
readonly worker_count=${7:-"3"}
readonly enable_opi_staging=${8:-""}
readonly storage_class=${9:-"hostpath"}
readonly diego_cell_count="${10:-"3"}"
readonly basedir="$(cd "$(dirname "$0")" && pwd)"

PIPELINE_YML=$(mktemp)
export PIPELINE_YML

dhall-fly <<<"$basedir/pipeline.dhall $worker_count" >"$PIPELINE_YML"

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
  --var gcs-json-key="$(pass eirini/gcs-json-key)" \
  --var eirini-release-branch="$eirini_release_branch" \
  --var eirini-branch="$eirini_branch" \
  --var worker_count="$worker_count" \
  --var storage_class="$storage_class" \
  --var enable_opi_staging="${enable_opi_staging}" \
  --var diego-cell-count="$diego_cell_count" \
  --load-vars-from "$private_repo/concourse/common.yml"
