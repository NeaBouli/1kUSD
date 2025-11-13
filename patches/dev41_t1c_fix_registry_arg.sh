#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1c: use MockParameterRegistry in OracleAggregator constructor =="

for f in foundry/test/oracle/OracleRegression_Base.t.sol foundry/test/oracle/OracleRegression_Watcher.t.sol; do
  [ -f "$f" ] || continue
  # Import und Deklaration einfügen
  if ! grep -q "MockParameterRegistry" "$f"; then
    sed -i.bak 's|import "contracts/core/OracleAggregator.sol";|import "contracts/core/OracleAggregator.sol";\
import "contracts/mocks/MockParameterRegistry.sol";|' "$f"
    sed -i '' 's|OracleAggregator aggregator;|OracleAggregator aggregator;\
    MockParameterRegistry registry;|' "$f"
  fi
  # Konstruktorzeile ersetzen
  sed -i '' 's|new OracleAggregator(address(this), safety,.*)|registry = new MockParameterRegistry();\
        aggregator = new OracleAggregator(address(this), safety, registry);|' "$f"
done

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1c: added MockParameterRegistry to oracle regression tests\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ OracleAggregator registry argument fixed."
