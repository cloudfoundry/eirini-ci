#!/bin/bash

set -euo pipefail
# set -x

repos=("eirini" "eirini-release" "eirini-ci")

branch-age() {
  local branch common_commit_sha first_wip_sha first_wip_time current_time day
  branch="$1"

  common_commit_sha="$(git merge-base master $branch)"
  first_wip_sha="$(git rev-list --topo-order $common_commit_sha..$branch | tail -1)"
  fist_wip_time="$(git show -s --format=%at $first_wip_sha)"
  current_time=$(date +%s)

  day=$((24 * 3600))
  echo $((($current_time - $fist_wip_time) / $day))
}

main() {
  aged_branches=()
  for repo in ${repos[@]}; do
    echo "Checking for aging wip branches in $repo"
    git clone "https://github.com/cloudfoundry-incubator/${repo}"
    pushd "$repo" || exit 1
    {
      for branch in $(git branch --remote | grep wip | grep -v spike); do
        branch_age="$(branch-age "$branch")"
        if ((branch_age > 2)); then
          aged_branches+=("${repo}:${branch}")
        fi
      done
    }
    popd || exit 1
  done

  if [[ ${#aged_branches[@]} -gt 0 ]]; then
    echo "Found the following aged wip branches:"
    printf '%s\n' "${aged_branches[@]}"
    exit 1
  fi
}

main "$@"
