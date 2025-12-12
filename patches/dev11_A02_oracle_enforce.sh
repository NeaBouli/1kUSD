#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PYEOF'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# 1) IOracleHealthModule nach pragma solidity einfügen (idempotent)
if "interface IOracleHealthModule" not in text:
    pragma_idx = text.find("pragma solidity")
    assert pragma_idx != -1, "pragma solidity not found"
    semi_idx = text.find(";", pragma_idx)
    assert semi_idx != -1, "pragma line has no semicolon"
    insert_pos = semi_idx + 1
    iface_snippet = (
        "\n\ninterface IOracleHealthModule { "
        "function isHealthy() external view returns (bool); "
        "}\n"
    )
    text = text[:insert_pos] + iface_snippet + text[insert_pos:]

# 2) Health-Gate-Errors nach ZERO_AMOUNT einfügen (idempotent)
if "BUYBACK_ORACLE_UNHEALTHY" not in text:
    err_anchor = "error ZERO_AMOUNT();"
    idx = text.find(err_anchor)
    assert idx != -1, "ZERO_AMOUNT error not found"
    insert_pos = idx + len(err_anchor)
    err_insert = " error BUYBACK_ORACLE_UNHEALTHY(); error BUYBACK_GUARDIAN_STOP();"
    text = text[:insert_pos] + err_insert + text[insert_pos:]

# 3) State-Variablen für Health-Gate nach maxBuybackSharePerOpBps (idempotent)
if "oracleHealthModule" not in text:
    cap_anchor = "uint16 public maxBuybackSharePerOpBps;"
    idx = text.find(cap_anchor)
    assert idx != -1, "maxBuybackSharePerOpBps not found"
    insert_pos = idx + len(cap_anchor)
    state_insert = " address public oracleHealthModule; bool public oracleHealthGateEnforced;"
    text = text[:insert_pos] + state_insert + text[insert_pos:]

# 4) Event BuybackOracleHealthGateUpdated nach BuybackTreasuryCapUpdated (idempotent)
if "BuybackOracleHealthGateUpdated" not in text:
    evt_anchor = "event BuybackTreasuryCapUpdated"
    idx = text.find(evt_anchor)
    assert idx != -1, "BuybackTreasuryCapUpdated event not found"
    semi_idx = text.find(";", idx)
    assert semi_idx != -1, "BuybackTreasuryCapUpdated line has no semicolon"
    insert_pos = semi_idx + 1
    evt_insert = (
        " event BuybackOracleHealthGateUpdated("
        "address indexed oldModule, "
        "address indexed newModule, "
        "bool oldEnforced, "
        "bool newEnforced"
        ");"
    )
    text = text[:insert_pos] + evt_insert + text[insert_pos:]

# 5) _checkOracleHealthGate durch echte Enforcement-Logik ersetzen
func_marker = "function _checkOracleHealthGate"
start = text.find(func_marker)
assert start != -1, "_checkOracleHealthGate function not found"

brace_idx = text.find("{", start)
assert brace_idx != -1, "no { after _checkOracleHealthGate signature"

depth = 0
end_idx = None
for i, c in enumerate(text[brace_idx:], start=brace_idx):
    if c == "{":
        depth += 1
    elif c == "}":
        depth -= 1
        if depth == 0:
            end_idx = i
            break

assert end_idx is not None, "could not find end of _checkOracleHealthGate body"

new_func = (
    "function _checkOracleHealthGate() internal view { "
    "if (!oracleHealthGateEnforced) { return; } "
    "address module = oracleHealthModule; "
    "if (module == address(0)) { revert BUYBACK_ORACLE_UNHEALTHY(); } "
    "if (!IOracleHealthModule(module).isHealthy()) { "
    "revert BUYBACK_ORACLE_UNHEALTHY(); "
    "} "
    "}"
)

text = text[:start] + new_func + text[end_idx + 1:]

# 6) DAO-Setter setOracleHealthGateConfig nach setMaxBuybackSharePerOpBps einfügen (idempotent)
if "setOracleHealthGateConfig(" not in text:
    sig = "function setMaxBuybackSharePerOpBps(uint16 newCapBps)"
    idx = text.find(sig)
    assert idx != -1, "setMaxBuybackSharePerOpBps not found"
    brace_idx = text.find("{", idx)
    assert brace_idx != -1, "no { after setMaxBuybackSharePerOpBps"

    depth = 0
    end_idx = None
    for i, c in enumerate(text[brace_idx:], start=brace_idx):
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end_idx = i
                break

    assert end_idx is not None, "could not find end of setMaxBuybackSharePerOpBps body"
    insert_pos = end_idx + 1

    setter = (
        " function setOracleHealthGateConfig(address newModule, bool newEnforced) "
        "external onlyDAO { "
        "address oldModule = oracleHealthModule; "
        "bool oldEnforced = oracleHealthGateEnforced; "
        "if (newEnforced && newModule == address(0)) { revert BUYBACK_ORACLE_UNHEALTHY(); } "
        "oracleHealthModule = newModule; "
        "oracleHealthGateEnforced = newEnforced; "
        "emit BuybackOracleHealthGateUpdated(oldModule, newModule, oldEnforced, newEnforced); "
        "}"
    )

    text = text[:insert_pos] + setter + text[insert_pos:]

path.write_text(text)
PYEOF

# DEV-11 A02 Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 A02 oracle_enforce: wire oracle health gate enforcement into BuybackVault" >> logs/project.log

echo "== DEV-11 A02: oracle/health gate enforcement wired into BuybackVault =="

forge test
mkdocs build

echo "== DEV-11 A02 oracle_enforce done =="
