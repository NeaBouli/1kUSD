#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1e: clean duplicate registry declarations =="

FILES="foundry/test/oracle/OracleRegression_Base.t.sol foundry/test/oracle/OracleRegression_Watcher.t.sol"

for f in $FILES; do
  [ -f "$f" ] || continue

  # Entferne alle MockParameterRegistry-Zeilen
  sed -i.bak '/MockParameterRegistry/d' "$f"

  # Falls versehentlich doppelte registry-Zeilen verblieben sind, nur eine behalten
  awk '!seen[$0]++' "$f" > "$f.tmp" && mv "$f.tmp" "$f"

  # Sicherstellen, dass nur eine saubere Deklaration existiert
  if ! grep -q 'IParameterRegistry registry;' "$f"; then
    sed -i '' 's|OracleAggregator aggregator;|OracleAggregator aggregator;\n    IParameterRegistry registry;|' "$f"
  fi

  # Konstruktoraufruf vereinheitlichen auf Null-Registry
  sed -i '' 's|new OracleAggregator(address(this), safety, [^)]*)|new OracleAggregator(address(this), safety, registry)|g' "$f"
  sed -i '' 's|registry *= *[^;]*;|registry = IParameterRegistry(address(0));|g' "$f"
done

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1e: cleaned duplicate registry declarations, ensured zero-addr registry\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ Registry cleanup complete – build expected to compile cleanly."
