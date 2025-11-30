#!/usr/bin/env bash
set -euo pipefail

echo "== DEV91 DOC01: add Economic Layer Status box to README =="

FILE="README.md"
LOG_FILE="logs/project.log"

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

snippet = """
## Economic Layer Status

> **Baseline vs. Preview**
>
> The current on-chain design is intentionally split into:
>
> - **Economic Layer v0.51.0 (Baseline)**  
>   Stable core including PSM, Oracle layer, Guardian/SafetyAutomata and
>   BuybackVault. This is the reference behaviour for mainnet.
>
> - **BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Preview)**  
>   An *optional* policy guard on top of the existing BuybackVault logic.
>   It introduces:
>   - a DAO-controlled flag: `strategiesEnforced` (default: `false`)
>   - additional reverts in `executeBuyback()` when enforcement is enabled:
>     `NO_STRATEGY_CONFIGURED` and `NO_ENABLED_STRATEGY_FOR_ASSET`.
>
> As long as `strategiesEnforced == false`, the protocol behaves exactly like
> **v0.51.0**. Turning the flag on is a **separate governance decision** and
> should be coupled with:
>
> - updated monitoring (indexer views & dashboards),
> - a clear parameter vote,
> - and coordination with Risk / Security / PoR runbooks.
>
> For details, see:
> - `docs/architecture/buybackvault_strategy_phase1.md`
> - `docs/governance/parameter_playbook.md`
> - `docs/indexer/indexer_buybackvault.md`
> - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
"""

marker = "## Economic Layer Status"
if marker in text:
    print("Economic Layer Status section already present; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Bevorzugter Anker: Architektur/Status-Bereich
    for i, line in enumerate(lines):
        if "## Architecture" in line or "## Architektur" in line:
            insert_idx = i
            break

    if insert_idx is None:
        # Fallback: am Ende anfügen
        print("No obvious Architecture marker found; appending Economic Layer Status at end.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting Economic Layer Status section before line {insert_idx}.")
        lines.insert(insert_idx, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ Economic Layer Status section written/updated in README.md")
PY

# Log-Eintrag
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-91] ${timestamp} README: added Economic Layer Status box (baseline vs StrategyEnforcement preview)." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV91 DOC01: done =="
