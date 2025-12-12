#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BUYBACK_VAULT="contracts/core/BuybackVault.sol"

python - << 'PYEOF'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# 1) Sanity: helper noch nicht vorhanden
assert "_applyBuybackWindowCap(" not in text, "_applyBuybackWindowCap already present"

# 2) Neue Error: BuybackWindowCapExceeded direkt nach BuybackPerOpTreasuryCapExceeded einfügen
err_needle = "error BuybackPerOpTreasuryCapExceeded();"
assert err_needle in text, "BuybackPerOpTreasuryCapExceeded error not found"
text = text.replace(
    err_needle,
    err_needle + " error BuybackWindowCapExceeded();",
    1,
)

# 3) Helper-Funktion nach _checkOracleHealthGate() einfügen
fn_needle = "function _checkOracleHealthGate() internal view"
idx = text.find(fn_needle)
assert idx != -1, "_checkOracleHealthGate function not found"

brace_start = text.find("{", idx)
assert brace_start != -1, "opening brace of _checkOracleHealthGate not found"

depth = 0
end_idx = None
for i in range(brace_start, len(text)):
    c = text[i]
    if c == "{":
        depth += 1
    elif c == "}":
        depth -= 1
        if depth == 0:
            end_idx = i
            break

assert end_idx is not None, "could not find end of _checkOracleHealthGate body"

insert_pos = end_idx + 1

helper = (
    " function _applyBuybackWindowCap(uint256 amountStable) internal {"
    " uint16 windowCap = maxBuybackSharePerWindowBps;"
    " uint64 duration = buybackWindowDuration;"
    " if (windowCap == 0 || duration == 0) { return; }"
    " uint256 treasuryBalance = stableToken.balanceOf(address(this));"
    " if (treasuryBalance == 0) { return; }"
    " uint64 ts = uint64(block.timestamp);"
    " uint64 start = buybackWindowStart;"
    " if (start == 0 || ts >= start + duration) {"
    " buybackWindowStart = ts;"
    " buybackWindowAccumulatedBps = 0;"
    " start = ts;"
    " }"
    " uint256 deltaBps = (amountStable * 10000) / treasuryBalance;"
    " uint256 newAccumulated = uint256(buybackWindowAccumulatedBps) + deltaBps;"
    " if (newAccumulated > windowCap) { revert BuybackWindowCapExceeded(); }"
    " buybackWindowAccumulatedBps = uint128(newAccumulated);"
    " }"
)

text = text[:insert_pos] + helper + text[insert_pos:]

def first_param_name(src: str, fn_name: str) -> str:
    """Extract name of the first parameter of function fn_name(...)."""
    fn_idx = src.find(f"function {fn_name}")
    if fn_idx == -1:
        raise AssertionError(f"function {fn_name} not found")
    paren_open = src.find("(", fn_idx)
    paren_close = src.find(")", paren_open)
    if paren_open == -1 or paren_close == -1:
        raise AssertionError(f"could not find parameter list for {fn_name}")
    params = src[paren_open + 1:paren_close]
    # first param chunk, e.g. 'uint256 amount' or 'uint256 amountStable'
    first = params.split(",")[0].strip()
    # last token is the name
    name = first.split()[-1]
    return name

def inject_window_call(src: str, fn_name: str) -> str:
    param = first_param_name(src, fn_name)
    fn_idx = src.find(f"function {fn_name}")
    assert fn_idx != -1, f"{fn_name} not found"
    body_start = src.find("{", fn_idx)
    assert body_start != -1, f"{fn_name} body start not found"
    next_fn = src.find("function ", body_start + 1)
    search_end = len(src) if next_fn == -1 else next_fn
    hook = "_checkOracleHealthGate();"
    hook_idx = src.find(hook, body_start, search_end)
    assert hook_idx != -1, f"_checkOracleHealthGate call not found in {fn_name}"
    insert_at = hook_idx + len(hook)
    insertion = f" _applyBuybackWindowCap({param});"
    return src[:insert_at] + insertion + src[insert_at:]

# 4) Call in executeBuybackPSM
text = inject_window_call(text, "executeBuybackPSM")

# 5) Call in executeBuyback
text = inject_window_call(text, "executeBuyback")

path.write_text(text)
PYEOF

# DEV-11 A03 Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 A03 window_accounting: enforce rolling window cap on cumulative buybacks in BuybackVault" >> logs/project.log

echo "== DEV-11 A03: window accounting & cap enforcement patch applied =="

forge test
mkdocs build

echo "== DEV-11 A03 window_accounting done =="
