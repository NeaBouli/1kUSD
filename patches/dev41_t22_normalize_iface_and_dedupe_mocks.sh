#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T22: Normalize safety to interface + dedupe mock injections =="

cp -n "$FILE" "${FILE}.bak.t22" || true

awk '
  BEGIN {
    addedIfaceImport=0
    seenSafetyDecl=0
    seenMockSafety=0
    seenMockRegistry=0
    seenSafetyAssign=0
    seenRegistryAssign=0
  }
  # 1) Ensure ISafetyAutomata import exists (after any SafetyAutomata import or IParameterRegistry import)
  /contracts\/core\/SafetyAutomata\.sol/ { print; next }
  /contracts\/interfaces\/ISafetyAutomata\.sol/ { addedIfaceImport=1; print; next }
  /contracts\/interfaces\/IParameterRegistry\.sol/ {
      print
      if (!addedIfaceImport) {
          print "import \"contracts/interfaces/ISafetyAutomata.sol\";"
          addedIfaceImport=1
      }
      next
  }

  # 2) Normalize field declaration: SafetyAutomata safety;  -> ISafetyAutomata safety;
  {
    # Match a plain field decl of SafetyAutomata safety;
    if ($0 ~ /^[[:space:]]*SafetyAutomata[[:space:]]+safety[[:space:]]*;/) {
        sub(/SafetyAutomata[[:space:]]+safety/, "ISafetyAutomata safety")
        print
        seenSafetyDecl=1
        next
    }
  }

  # 3) Dedupe mock instantiations inside setUp: keep first, drop further
  /SafetyAutomata[[:space:]]+mockSafety[[:space:]]*=/ {
      if (seenMockSafety) next
      seenMockSafety=1
      # normalize constructor to (address(this), 0)
      gsub(/new[[:space:]]+SafetyAutomata[[:space:]]*\([^)]*\)/, "new SafetyAutomata(address(this), 0)")
      print
      next
  }
  /ParameterRegistry[[:space:]]+mockRegistry[[:space:]]*=/ {
      if (seenMockRegistry) next
      seenMockRegistry=1
      print
      next
  }

  # 4) Normalize assignments: safety = mockSafety;  / registry = mockRegistry;
  /safety[[:space:]]*=/ {
      if (seenSafetyAssign) next
      # replace any casted assignment to a direct upcast
      sub(/safety[[:space:]]*=.*/, "safety = mockSafety;")
      print
      seenSafetyAssign=1
      next
  }
  /registry[[:space:]]*=/ {
      if (seenRegistryAssign) next
      sub(/registry[[:space:]]*=.*/, "registry = mockRegistry;")
      print
      seenRegistryAssign=1
      next
  }

  # 5) Default: print line
  { print }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ safety field uses interface, ISafetyAutomata import ensured, mocks deduped, assignments normalized."
