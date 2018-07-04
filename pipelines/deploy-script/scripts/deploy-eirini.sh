#!/bin/bash

(
  cd "$EIRINI_LITE" || exit 1
  git clone https://github.com/cloudfoundry-incubator/eirini-release.git

	# shellcheck source=/dev/null
	"$EIRINI_LITE"/eirini-release/scripts/lite/come-on-eirini.sh
)
