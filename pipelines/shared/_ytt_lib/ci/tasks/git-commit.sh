#!/bin/bash

set -euo pipefail

if [[ -d "${COMMIT_MSG_DIR:-}" ]]; then
  COMMIT_MSG=$(cat "${COMMIT_MSG_DIR}/message")
fi

pushd "$REPO"
{
  if git status --porcelain | grep .; then
    echo "Repo is dirty"
    git add "$ADD_PATH"
    git --no-pager diff --staged
    git config --global user.email "eirini@cloudfoundry.org"
    git config --global user.name "Come-On Eirini"
    git commit --all --message "$COMMIT_MSG"
  else
    echo "Repo is clean"
  fi
}
popd

cp -r "$REPO"/. "$REPO_MODIFIED"
