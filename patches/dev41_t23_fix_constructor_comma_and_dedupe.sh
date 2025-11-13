#!/usr/bin/env bash
set -euo pipefail
FILE="foundry/test/oracle/OracleRegression_Base.t.sol"
TMP="${FILE}.tmp"

echo "== DEV-41-T23: Fix SafetyAutomata constructor comma + dedupe mock lines =="

cp -n "$FILE" "${FILE}.bak.t23" || true

awk '
  BEGIN {
    seenMockSafety=0
    seenMockRegistry=0
    seenSafetyAssign=0
    seenRegistryAssign=0
  }
  {
    line=$0

    # 1) Repariere den fehlerhaften Konstruktor: ... 0), 0);
    if (line ~ /new[[:space:]]+SafetyAutomata[[:space:]]*\(address\(this\),[[:space:]]*0\)[[:space:]]*,[[:space:]]*0\)[[:space:]]*;/) {
      gsub(/, *0\) *;/, ");", line)
    }

    # 2) Dedupe Mock-Deklarationen
    if (line ~ /^[[:space:]]*SafetyAutomata[[:space:]]+mockSafety[[:space:]]*=/) {
      if (seenMockSafety) next
      seenMockSafety=1
    }
    if (line ~ /^[[:space:]]*ParameterRegistry[[:space:]]+mockRegistry[[:space:]]*=/) {
      if (seenMockRegistry) next
      seenMockRegistry=1
    }

    # 3) Normalisiere Zuweisungen auf genau eine Zeile jeweils
    if (line ~ /^[[:space:]]*safety[[:space:]]*=/) {
      if (seenSafetyAssign) next
      line="        safety = mockSafety;"
      seenSafetyAssign=1
    }
    if (line ~ /^[[:space:]]*registry[[:space:]]*=/) {
      if (seenRegistryAssign) next
      line="        registry = mockRegistry;"
      seenRegistryAssign=1
    }

    print line
  }
' "$FILE" > "$TMP" && mv "$TMP" "$FILE"

echo "✅ Constructor fixed and mock lines deduped."
