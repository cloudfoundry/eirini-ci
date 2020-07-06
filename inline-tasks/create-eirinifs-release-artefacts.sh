#!/bin/bash

set -euo pipefail

cp eirinifs-image/rootfs.tar eirinifs-artefacts/eirinifs.tar
sha256sum "eirinifs-image/rootfs.tar" | awk '{print $1}' >"eirinifs-artefacts/eirinifs.tar.sha256"
