#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T8: Inject inline MinimalMockRegistry implementation =="

cp -n "$FILE" "${FILE}.bak" || true

awk '
  NR==1 { print; next }
  NR==2 {
    print "";
    print "// Inline minimal registry to bypass ZERO_ADDRESS() revert";
    print "contract MinimalMockRegistry is IParameterRegistry {";
    print "    function getParam(bytes32) external pure returns (uint256) { return 0; }";
    print "    function admin() external pure returns (address) { return address(0xA11CE); }";
    print "}";
    print "";
  }
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

# Replace registry instantiation to use MinimalMockRegistry instead of MockRegistry
sed -i '' 's/address(new MockRegistry())/address(new MinimalMockRegistry())/' "$FILE"

echo "✅ Inline MinimalMockRegistry injected and used in setup."
