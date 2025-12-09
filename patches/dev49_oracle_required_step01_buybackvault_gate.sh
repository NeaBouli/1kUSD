#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# 1) Neues Error BUYBACK_ORACLE_REQUIRED() nach ZERO_AMOUNT einfügen
if "BUYBACK_ORACLE_REQUIRED" not in text:
    marker = "error ZERO_AMOUNT();"
    if marker not in text:
        raise SystemExit("marker 'error ZERO_AMOUNT();' not found in BuybackVault.sol")
    insert = marker + "\n    error BUYBACK_ORACLE_REQUIRED();"
    text = text.replace(marker, insert)

# 2) _checkOracleHealthGate-Implementierung durch Version mit BUYBACK_ORACLE_REQUIRED ersetzen
fn_sig = "function _checkOracleHealthGate() internal view"
idx = text.find(fn_sig)
if idx == -1:
    raise SystemExit("function _checkOracleHealthGate not found in BuybackVault.sol")

brace_start = text.find("{", idx)
if brace_start == -1:
    raise SystemExit("opening brace for _checkOracleHealthGate not found")

depth = 0
end = None
for i, ch in enumerate(text[brace_start:], start=brace_start):
    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            end = i
            break

if end is None:
    raise SystemExit("could not find end of _checkOracleHealthGate function block")

old_block = text[idx:end+1]

new_block = """    function _checkOracleHealthGate() internal view {
        if (!oracleHealthGateEnforced) {
            return;
        }
        address module = oracleHealthModule;
        if (module == address(0)) {
            revert BUYBACK_ORACLE_REQUIRED();
        }
        if (!IOracleHealthModule(module).isHealthy()) {
            revert BUYBACK_ORACLE_UNHEALTHY();
        }
    }
"""

text = text.replace(old_block, new_block)

path.write_text(text)
PY

# 3) Log-Eintrag
echo "[DEV-49 step01] $(date -u +"%Y-%m-%dT%H:%M:%SZ") introduce BUYBACK_ORACLE_REQUIRED in BuybackVault oracle health gate" >> logs/project.log

echo "== DEV-49 step01: BuybackVault oracle gate updated with BUYBACK_ORACLE_REQUIRED =="
