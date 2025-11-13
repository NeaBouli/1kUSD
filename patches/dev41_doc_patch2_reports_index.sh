#!/usr/bin/env bash
set -euo pipefail

FILE="reports/README.md"
TMP="${FILE}.tmp"

echo "== DEV-41 Patch 2: Insert DEV41 into reports index =="

cp -n "$FILE" "${FILE}.bak.dev41p2" || true

awk '
  BEGIN{inserted=0}
  {
    print
    # Insert after the last DEV-XX line (matching pattern)
    if ($0 ~ /^- DEV-4[0-9]/ && !inserted) {
      print "- DEV-41 — Oracle Regression Stabilization (see: docs/reports/DEV41_ORACLE_REGRESSION.md)"
      inserted=1
    }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ Injected DEV-41 into reports/README.md"
