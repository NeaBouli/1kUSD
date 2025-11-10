#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-40 Step 8: Docs Update & ADR Extension =="

DOC="docs/adr/ADR-040-oracle-watcher.md"
TMP="${DOC}.tmp"

awk '
/## Consequences/ {
  print
  print ""
  print "## Implementation Notes (Phase 1-2)"
  print ""
  print "- OracleWatcher scaffold, wiring, and neutral health view complete."
  print "- Added connector variables (oracle, safetyAutomata) and constructor wiring."
  print "- Introduced HealthState struct and Status enum."
  print "- Added functional skeleton methods (updateHealth, refreshState)."
  print "- Implemented neutral read-only accessors:"
  print "  - isHealthy() → returns true until cache active"
  print "  - getStatus(), lastUpdate(), hasCache()"
  print ""
  print "Next: Phase 3 will implement actual binding logic to OracleAggregator and SafetyAutomata."
  next
}
{ print }
' "$DOC" > "$TMP" && mv "$TMP" "$DOC"

mkdir -p logs
printf "%s DEV-40 step8: updated ADR-040 docs for OracleWatcher phase1-2 completion (no builds)\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ DEV-40 Step 8 applied – ADR-040 updated (no builds)."
