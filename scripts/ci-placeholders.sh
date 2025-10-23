#!/usr/bin/env bash
set -euo pipefail
DIR="${1:-reports}"
mkdir -p "$DIR"

Lint placeholder

echo "lint ok" > "$DIR/lint.txt"

Unit placeholder

cat > "$DIR/unit.json" <<JSON
{ "suite":"unit","passed":0,"failed":0,"skipped":0,"durationMs":0,"coverage":{"statements":0,"branches":0,"functions":0} }
JSON

Invariants placeholder

cat > "$DIR/invariants.json" <<JSON
{ "invariants":[{"name":"I1","checks":0,"violations":0,"maxSteps":0,"seed":"0x00"}] }
JSON

Static analysis placeholder

cat > "$DIR/slither.json" <<JSON
{ "tool":"slither","version":"0.0.0","findings":[] }
JSON
cat > "$DIR/mythril.json" <<JSON
{ "tool":"mythril","version":"0.0.0","findings":[] }
JSON

Gas placeholder

cat > "$DIR/gas.json" <<JSON
{ "methods":[{"name":"PSM.swapTo1kUSD","gas":0}],"commit":"<sha>"}
JSON

Security rollup placeholder

cat > "$DIR/security-findings.json" <<JSON
{ "summary":{"critical":0,"high":0,"medium":0,"low":0}, "findings":[] }
JSON
