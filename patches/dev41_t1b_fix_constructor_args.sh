#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1b: fix OracleAggregator constructor args in regression tests =="

# Konstruktoraufrufe anpassen: 2 → 3 Parameter
for f in foundry/test/oracle/OracleRegression_Base.t.sol foundry/test/oracle/OracleRegression_Watcher.t.sol; do
  [ -f "$f" ] || continue
  sed -i.bak 's|new OracleAggregator(address(this), safety)|new OracleAggregator(address(this), safety, keccak256("ORACLE"))|g' "$f"
done

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1b: fixed OracleAggregator constructor args in oracle regression tests\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ OracleAggregator constructor arguments fixed."
