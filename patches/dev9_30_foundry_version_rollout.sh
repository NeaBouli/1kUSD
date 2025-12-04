#!/bin/bash
set -e

echo "== DEV-9 30: rollout canonical Foundry version to all workflows =="

CANONICAL_FILE=".github/workflows/foundry.yml"

if [ ! -f "$CANONICAL_FILE" ]; then
  echo "Canonical Foundry workflow $CANONICAL_FILE not found, aborting."
  exit 1
fi

# Erste "version:"-Zeile aus dem kanonischen Workflow holen
CANONICAL_VERSION="$(awk '/version:[[:space:]]+/ {print $2; exit}' "$CANONICAL_FILE")"

if [ -z "$CANONICAL_VERSION" ]; then
  echo "Could not detect canonical Foundry version from $CANONICAL_FILE (no 'version:' line found), aborting."
  exit 1
fi

echo "Canonical Foundry version detected: $CANONICAL_VERSION"

# Alle anderen Workflows, die foundry-toolchain nutzen, auf diese Version ziehen
for f in .github/workflows/*.yml; do
  if [ "$f" = "$CANONICAL_FILE" ]; then
    continue
  fi

  if grep -q "foundry-rs/foundry-toolchain" "$f"; then
    echo "Patching $f"
    tmp="${f}.tmp"
    awk -v ver="$CANONICAL_VERSION" '
      /uses: .*foundry-rs\/foundry-toolchain/ {
        in_block=1
        print
        next
      }
      in_block && /version:/ {
        sub(/version:.*/, "version: " ver)
        in_block=0
        print
        next
      }
      { print }
    ' "$f" > "$tmp"
    mv "$tmp" "$f"
  fi
done

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 30] ${timestamp} Rolled out canonical Foundry version from $CANONICAL_FILE to other workflows" >> "$LOG_FILE"

echo "== DEV-9 30 done =="
