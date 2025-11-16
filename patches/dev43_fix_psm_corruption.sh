#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-43 Hotfix: Repair corrupted PegStabilityModule.sol =="

# 1. Entferne die kaputte Import-Zeile
sed -i '' 's/; from "\.\.\/interfaces\/IPSM\.sol";//' "$FILE"

# 2. Füge korrekte Imports hinzu (falls nicht vorhanden)
if ! grep -q 'import {IPSMEvents}' "$FILE"; then
  sed -i '' '/import {IPSM} from "..\/interfaces\/IPSM.sol";/a\
import {IPSMEvents} from "../interfaces/IPSMEvents.sol";\
' "$FILE"
fi

# 3. Contract-Header fixen (einmalig)
sed -i '' 's/contract PegStabilityModule is IPSM,/contract PegStabilityModule is IPSM, IPSMEvents,/' "$FILE"

# 4. Fix constructor-Klammerfehler: Falls nach constructor KEIN "{" → restore structure
sed -i '' 's/constructor(address admin, address _oneKUSD, address _vault, address _auto, address _reg) {/constructor(address admin, address _oneKUSD, address _vault, address _auto, address _reg) {\n        _grantRole(DEFAULT_ADMIN_ROLE, admin);\n        _grantRole(ADMIN_ROLE, admin);\n        oneKUSD = OneKUSD(_oneKUSD);\n        vault = CollateralVault(_vault);\n        safetyAutomata = ISafetyAutomata(_auto);\n        registry = ParameterRegistry(_reg);\n    }\n/' "$FILE"

# 5. Lösche vollständig die beschädigten swapTo1kUSD/swapFrom1kUSD-Fragmente
sed -i '' '/function PSMSwapExecuted/,+20d' "$FILE"

echo "✓ PegStabilityModule syntactically repaired"
echo "== Hotfix Complete =="
