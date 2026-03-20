#!/usr/bin/env bash
set -euo pipefail
cat <<EOF
release_owner=${RELEASE_OWNER:-sre-platform}
release_repo=${RELEASE_REPO:-ansible-azure-enterprise}
release_sha=${GIT_SHA:-unknown}
release_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
