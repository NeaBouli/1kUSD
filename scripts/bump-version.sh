#!/usr/bin/env bash

Usage: ./scripts/bump-version.sh <major|minor|patch> [--no-tag]

set -euo pipefail
PART="${1:-patch}"
NOTAG="${2:-}"
CURRENT="$(git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0)"
BASE="${CURRENT#v}"
IFS='.' read -r MA MI PA <<<"$BASE"
case "$PART" in
major) MA=$((MA+1)); MI=0; PA=0 ;;
minor) MI=$((MI+1)); PA=0 ;;
patch) PA=$((PA+1)) ;;
*) echo "unknown part: $PART"; exit 1 ;;
esac
NEW="v${MA}.${MI}.${PA}"
echo "New version: $NEW (prev: $CURRENT)"
if [ "$NOTAG" != "--no-tag" ]; then
git tag -a "$NEW" -m "Release $NEW"
echo "Tagged $NEW"
fi
echo "$NEW"
