#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-41-T1d: use zero-address IParameterRegistry and fix ';;' =="

FILES="foundry/test/oracle/OracleRegression_Base.t.sol foundry/test/oracle/OracleRegression_Watcher.t.sol"

for f in $FILES; do
  [ -f "$f" ] || continue

  # 1) Toten Mock-Import entfernen (falls vorhanden)
  sed -i.bak '/contracts\/mocks\/MockParameterRegistry\.sol/d' "$f"

  # 2) IParameterRegistry-Import sicherstellen (einmalig nach OracleAggregator-Import)
  if ! grep -q 'contracts/interfaces/IParameterRegistry.sol' "$f"; then
    # nach der OracleAggregator-Importzeile einfügen
    awk '
      {print}
      /contracts\/core\/OracleAggregator\.sol/ && !done {
        print "import \"contracts/interfaces/IParameterRegistry.sol\";"
        done=1
      }
    ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi

  # 3) Deklaration für registry (auf Interface) sicherstellen
  if grep -q 'OracleAggregator aggregator;' "$f" && ! grep -q 'IParameterRegistry registry;' "$f"; then
    sed -i '' 's|OracleAggregator aggregator;|OracleAggregator aggregator;\n    IParameterRegistry registry;|' "$f"
  fi

  # 4) Konstruktoraufrufe vereinheitlichen:
  #    a) evtl. alte Mock-Zeile ersetzen durch Zero-Addr-Cast
  sed -i '' 's|registry = new MockParameterRegistry();|registry = IParameterRegistry(address(0));|g' "$f"

  #    b) Falls noch ein 3. Arg per keccak256 drin war -> auf registry umschreiben
  sed -i '' 's|new OracleAggregator(address(this), safety, *keccak256([^)]*)|new OracleAggregator(address(this), safety, registry|g' "$f"

  #    c) Falls noch 2-Arg-Variante existiert -> auf 3 Args mit registry umschreiben
  sed -i '' 's|new OracleAggregator(address(this), safety)|new OracleAggregator(address(this), safety, registry)|g' "$f"

  # 5) Doppelte Semikolons beseitigen
  sed -i '' 's|);;|);|g' "$f"
done

forge clean && forge build

mkdir -p logs
printf "%s DEV-41-T1d: switched to zero-address IParameterRegistry + fixed ;; syntax\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log
echo "✅ OracleAggregator registry arg resolved via IParameterRegistry(address(0)); syntax cleaned."
