#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1a: fix relative import paths in OracleRegression tests =="

# Dateien anpassen
for f in foundry/test/oracle/OracleRegression_Base.t.sol foundry/test/oracle/OracleRegression_Watcher.t.sol; do
  [ -f "$f" ] || continue
  sed -i.bak 's|\.\./\.\./contracts/|contracts/|g' "$f"
done

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1a: fixed import paths for oracle regression tests\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Imports in OracleRegression tests corrected."
