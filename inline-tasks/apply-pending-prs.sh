#!/usr/bin/env bash

set -euo pipefail

checkout-latest-release() {
  latest_release="$(git tag | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | sort --reverse | head -1)"
  git checkout "$latest_release"
  echo "checked out version: $latest_release"
}

trust_github() {
  mkdir -p "$HOME/.ssh"
  touch "$HOME/.ssh/known_hosts"
  ssh-keyscan -H github.com >>"$HOME/.ssh/known_hosts"
}

configure_git() {
  git config --global user.email "eirini@cloudfoundry.org"
  git config --global user.name "Come-On Eirini"
}

main() {
  local prs

  # shellcheck disable=SC2010
  prs=$(ls | grep -E 'pr-[0-9]+' | sed s/pr-//g)

  trust_github
  configure_git

  gh repo clone https://github.com/cloudfoundry/cf-for-k8s.git combined-prs

  pushd combined-prs
  {
    checkout-latest-release
    for pr in $prs; do
      echo "Applying PR: https://github.com/cloudfoundry/cf-for-k8s/pull/$pr"
      if ! gh -R git@github.com:cloudfoundry/cf-for-k8s.git pr diff "$pr" | git apply -3; then
        # If git fails to apply the PR diff with a 3 way merge we assume that the currently
        # applied change is what we want. This should normally be correct as PRs are applied
        # in chronological order
        git checkout . --theirs
      fi

      git add .
      git commit -m "Apply https://github.com/cloudfoundry/cf-for-k8s/pull/$pr"
    done
  }

  popd
}

main
