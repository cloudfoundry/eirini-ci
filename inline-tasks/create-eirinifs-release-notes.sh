#!/bin/bash

set -euo pipefail

readonly RELEASE_NOTES="$PWD/release-notes/notes"

main() {
  touch "$RELEASE_NOTES"
  add-eirinifs-information
  add-cflinuxfs3-information
}

add-eirinifs-information() {
  local tag commits
  pushd eirinifs || exit 1
  tag="$(git describe --tags --abbrev=0)"
  commits="$(git log HEAD..."$tag" --format="%H %B%n")"

  if [[ -n "$commits" ]]; then
      commits="$(echo "$commits" | grep -v "Signed")"
      echo "This release includes the following commits:" >> "$RELEASE_NOTES"

      # shellcheck disable=SC2001
      echo "$commits" | sed -e 's/^/  /' >> "$RELEASE_NOTES"
  fi
  popd || exit 1
}

add-cflinuxfs3-information() {
  local tag
  tag="$(cat cflinuxfs3-release/tag)"
  {
    echo ""
    echo "This release includes the following cflinuxfs3 image:"
    echo "  Tag: $tag"
  } >> "$RELEASE_NOTES"
}

main
