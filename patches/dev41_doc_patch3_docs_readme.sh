#!/usr/bin/env bash
set -euo pipefail

FILE="docs/README.md"
TMP="${FILE}.tmp"

echo "== DEV-41 Patch 3: Add DEV41 to docs/README.md =="

cp -n "$FILE" "${FILE}.bak.dev41p3" || true

awk '
  BEGIN { inserted=0 }
  {
    print

    # Insert DEV-41 entry right after the reports section header or after existing DEV entries
    if ($0 ~ /Release & Versioning/ && !inserted) {
      # do nothing here, insertion will happen when list starts
      next
    }

    # When hitting a list element under this section, inject DEV41 once
    if (!inserted && $0 ~ /^- DEV-4[0-9]/) {
      print "- DEV-41 – Oracle Regression Stabilization Report"
      inserted=1
    }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✓ docs/README.md updated with DEV-41 entry"
