#!/bin/bash
set -euo pipefail

curl -k -X PUT -u "admin:$JEFE_ADMIN_PASSWORD" "$JEFE_URL/envs/unclaim"
