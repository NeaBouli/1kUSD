#!/usr/bin/env bash
set -e
LOG_DIR="docs/logs"
LOG_FILE="${LOG_DIR}/docs_structure_scan.log"
REPORT="${LOG_DIR}/routing_fix_report.md"

mkdir -p "$LOG_DIR"

echo "📘 Docs Structure Scan — $(date)" > "$LOG_FILE"
echo "================================" >> "$LOG_FILE"
echo >> "$LOG_FILE"

if command -v tree >/dev/null 2>&1; then
  tree docs >> "$LOG_FILE"
else
  find docs -type f | sort >> "$LOG_FILE"
fi

FIX_COUNT=0
if [ -f "docs/governance.md" ]; then
  mv docs/governance.md docs/GOVERNANCE.md
  echo "Renamed governance.md → GOVERNANCE.md" >> "$REPORT"
  FIX_COUNT=$((FIX_COUNT+1))
fi
if [ -f "docs/logs/Project.md" ]; then
  mv docs/logs/Project.md docs/logs/project.md
  echo "Renamed logs/Project.md → logs/project.md" >> "$REPORT"
  FIX_COUNT=$((FIX_COUNT+1))
fi

MISSING=0
for f in docs/GOVERNANCE.md docs/logs/project.md; do
  if [ ! -f "\$f" ]; then
    echo "❌ Missing file: \$f" >> "\$REPORT"
    MISSING=\$((MISSING+1))
  fi
done

{
  echo "# Routing Fix Report"
  echo "- Timestamp: \$(date)"
  echo "- Fixes Applied: \$FIX_COUNT"
  echo "- Missing Files: \$MISSING"
  echo
  echo "## Structure Snapshot"
  echo '```'
  cat "\$LOG_FILE"
  echo '```'
} > "\$REPORT"

if [ "\$MISSING" -gt 0 ]; then
  echo "❌ Missing required files. See \$REPORT"
  exit 1
else
  echo "✅ Docs structure OK — report written to \$REPORT"
fi
