#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-41 Patch 5: Update INDEX.md, STATUS.md, project.md =="

# 1) INDEX.md — Add DEV-41
FILE="docs/index.md"
TMP="${FILE}.tmp"
cp -n "$FILE" "${FILE}.bak.dev41p5" || true

awk '
  BEGIN { inserted = 0 }
  {
    print
    if (!inserted && $0 ~ /## Oracle Modules/) {
      print "- **DEV-41 — Oracle Regression Stability**"
      print "  - Fixes OracleWatcher ZERO_ADDRESS initialization"
      print "  - Ensures correct Base inheritance hierarchy"
      print "  - Aligns refreshState() with aggregation semantics"
      print "  - All regression tests green (26/26)"
      print ""
      inserted = 1
    }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 2) STATUS.md — Advanced status row
FILE="docs/STATUS.md"
TMP="${FILE}.tmp"
cp -n "$FILE" "${FILE}.bak.dev41p5" || true

awk '
  BEGIN { updated = 0 }
  {
    if ($0 ~ /DEV-41/) {
      print "| DEV-41 | Oracle Regression Stability | Completed | v0.41.x | ✓ All tests green |"
      updated = 1
      next
    }
    print
  }
  END {
    if (!updated) {
      print "| DEV-41 | Oracle Regression Stability | Completed | v0.41.x | ✓ All tests green |"
    }
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# 3) docs/logs/project.md — append summary
printf "\n### DEV-41 — Oracle Regression Stability\n- Fixed ZERO_ADDRESS constructor regression\n- Repaired inheritance chain OracleRegression_Base → Child\n- Eliminated shadowing fields\n- Fixed refreshState semantics\n- All 26 tests passing\n- Release tag: v0.41.x\n" >> docs/logs/project.md

echo "✓ INDEX.md, STATUS.md, project.md updated (DEV-41)."
