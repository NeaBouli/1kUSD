#!/usr/bin/env bash
set -euo pipefail

BASE="foundry/test/oracle/OracleRegression_Base.t.sol"
CHILD="foundry/test/oracle/OracleRegression_Watcher.t.sol"

echo "== DEV-41-T41: Make Base.setUp() virtual, fix shadowing; Child.setUp() override =="

cp -n "$BASE"  "${BASE}.bak.t41"  || true
cp -n "$CHILD" "${CHILD}.bak.t41" || true

# 1) Base: make setUp() virtual
#    - change `function setUp() public {` -> `function setUp() public virtual {`
#    - remove local var shadowing in setUp(): use member assigns instead
awk '
  BEGIN{in_setup=0}
  {
    line=$0
    # function signature to virtual (works if brace is same line)
    gsub(/function setUp\(\)[[:space:]]*public[[:space:]]*\{/,"function setUp() public virtual {", line)

    # detect we are inside setUp block (approximate)
    if (line ~ /function setUp\(\)[[:space:]]*public/) in_setup=1
    if (in_setup) {
      # replace shadowing declarations with assignments
      sub(/[[:space:]]*SafetyAutomata[[:space:]]+mockSafety[[:space:]]*=/,"        mockSafety =", line)
      sub(/[[:space:]]*ParameterRegistry[[:space:]]+mockRegistry[[:space:]]*=/,"        mockRegistry =", line)
    }
    # crude end-of-function detection: closing brace on its own line reduces risk
    if (in_setup && line ~ /^[[:space:]]*\}[[:space:]]*$/) in_setup=0

    print line
  }
' "$BASE" > "${BASE}.tmp" && mv "${BASE}.tmp" "$BASE"

# 2) Child: make setUp() override and keep super.setUp();
#    If child already calls super.setUp(), just ensure signature is override (not plain public).
awk '
  BEGIN{changed_sig=0}
  {
    line=$0
    if (!changed_sig && line ~ /function setUp\(\)[[:space:]]*public[[:space:]]*\{/ ) {
      sub(/function setUp\(\)[[:space:]]*public[[:space:]]*\{/,"function setUp() public override {", line)
      changed_sig=1
    }
    print line
  }
' "$CHILD" > "${CHILD}.tmp" && mv "${CHILD}.tmp" "$CHILD"

echo "✅ Base.setUp() is virtual, shadowing removed; Child.setUp() overrides."
