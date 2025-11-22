#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"

echo "== DEV57 DOC03: log governance/oracle doc wiring =="

mkdir -p "$(dirname "$LOG")"

cat <<EOL >> "$LOG"
[DEV-55] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Oracle tests: OracleRegression_Base harness aufgeräumt, Watcher-Refresh-Test an Health-Semantik angepasst; Oracle-Health-Stack weiter stabilisiert.
[DEV-56] $(date -u +"%Y-%m-%dT%H:%M:%SZ") README: Governance- und Parameter-Dokumente (Playbook, PSM-Parameter-Map, Economic Layer) direkt verlinkt.
[DEV-57] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Governance: docs/governance/index.md als Einstiegspunkt für Playbook & How-To angelegt (DE, rollenbasiert für DAO/Risk/Treasury).
EOL

echo "✓ DEV55–57 governance/oracle doc steps appended to $LOG"
