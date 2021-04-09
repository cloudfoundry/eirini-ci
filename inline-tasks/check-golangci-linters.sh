#!/bin/bash

set -euo pipefail

bold="\033[1m"
normal="\033[0m"

main() {
  # Catch invalid configuration or linters that no longer exist. Errors are printed to stderr
  golangci-lint linters >/dev/null

  unknown_linters="$(comm -3 <(yq eval '.linters.intentionally-disabled[].name' ./.golangci.yml | sort) <(golangci-lint linters | awk -F ':' '{ if (disabled==1) print $1 }; /Disabled by your/ { disabled=1 }' | sort))"
  if [[ -z "$unknown_linters" ]]; then
    exit 0
  fi

  echo -e "${bold}It seems that out golangci-lint configuration needs some attention${normal}"
  echo
  echo -e "${bold}Newly introduced linters (either enabled them, or document why we do not want to have them enabled):${normal}"
  comm -13 <(yq eval '.linters.intentionally-disabled[].name' ./.golangci.yml | sort) <(golangci-lint linters | awk -F ':' '{ if (disabled==1) print $1 }; /Disabled by your/ { disabled=1 }' | sort)
  echo
  echo -e "${bold}Intentionally disabled linters that no longer exist, please remove them from the intentionally disabled list:${normal}"
  comm -23 <(yq eval '.linters.intentionally-disabled[].name' ./.golangci.yml | sort) <(golangci-lint linters | awk -F ':' '{ if (disabled==1) print $1 }; /Disabled by your/ { disabled=1 }' | sort)

  exit 1
}

main "$@"
