#!/bin/bash
# Run from an app's root. Copies myKit's lint config at the version the app's Package.resolved pins:
#   .build/checkouts/mykit/scripts/sync-lint-config.sh
# The app's .swiftlint.yml points at the copy with `parent_config: .swiftlint-mykit.yml`.
set -euo pipefail
kit="$(cd "$(dirname "$0")/.." && pwd)"
cp "$kit/lint/swiftlint.yml" .swiftlint-mykit.yml
cp "$kit/.swift-format" .swift-format
echo "copied lint config from $kit"
