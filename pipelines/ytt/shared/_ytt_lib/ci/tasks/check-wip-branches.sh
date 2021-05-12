#!/bin/bash

set -euo pipefail

bold="\033[1m"
normal="\033[0m"
red="\033[31m"
yellow="\033[33m"

exclude="(gh-pages|develop|master)"
repos=("eirini" "eirini-release" "eirini-ci")

branch-age() {
  local branch common_commit_sha first_wip_sha first_wip_time current_time day
  branch="$1"

  common_commit_sha="$(git merge-base master "$branch")"
  first_wip_sha="$(git rev-list --topo-order "$common_commit_sha".."$branch" | tail -1)"

  # branches that were merged back into master do not have
  # diverging commits. Use the timestamp of the common commit
  # in these cases
  if [[ -z "$first_wip_sha" ]]; then
    first_wip_sha="$common_commit_sha"
  fi

  first_wip_time="$(git show -s --format=%at "$first_wip_sha")"
  current_time=$(date +%s)

  day=$((24 * 3600))
  echo $(((current_time - first_wip_time) / day))
}

main() {
  aged_wip_branches=()
  aged_spike_branches=()
  for repo in "${repos[@]}"; do
    echo "Checking for aging wip branches in $repo"

    git clone "https://github.com/cloudfoundry-incubator/${repo}"

    pushd "$repo" || exit 1
    {
      for branch in $(git branch --remote | grep -Ev $exclude); do
        branch_age="$(branch-age "$branch")"
        if ((branch_age > 2)); then
          if [[ $branch =~ spike ]]; then
            aged_spike_branches+=("$repo:$branch ($branch_age days)")
            continue
          fi

          aged_wip_branches+=("$repo:$branch ($branch_age days)")
        fi
      done
    }
    popd || exit 1
  done

  echo -e "${normal}"

  if [[ ${#aged_spike_branches[@]} -gt 0 ]]; then
    echo -e "${yellow}${bold}WARNING: ${yellow}Found the following aged spike branches:${normal}${yellow}"
    printf '%s\n' "${aged_spike_branches[@]}"
    echo -e "${normal}"
  fi

  if [[ ${#aged_wip_branches[@]} -gt 0 ]]; then
    echo -e "${red}${bold}ERROR: ${red}Found the following aged wip branches:${normal}${red}"
    printf '%s\n' "${aged_wip_branches[@]}"
    echo -e "${normal}"
    exit 1
  fi
}

main "$@"
