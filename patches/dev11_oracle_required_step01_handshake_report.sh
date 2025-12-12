#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# 1) DEV-11 OracleRequired Handshake Report schreiben
cat << 'MD' > docs/reports/DEV11_OracleRequired_Handshake_r1.md
# DEV-11 – OracleRequired Handshake (BuybackVault & PSM)

_Status: r1 – based on DEV-49 (OracleRequired)_

## 1. Purpose

This report is the formal handshake between **DEV-49 (OracleRequired)** and  
**DEV-11 (BuybackVault / Strategy / Tests)**.

It answers one simple question:

> What must DEV-11 *always* assume to be true after DEV-49?

From now on, every DEV-11 implementation, test and governance guideline must
treat **OracleRequired** as a _root safety layer_ of the protocol.

---

## 2. OracleRequired recap (from DEV-49)

DEV-49 introduced the following hard rules:

1. **Oracle is mandatory for BuybackVault in strict mode**

   - If `oracleHealthGateEnforced == true` and **no module is set**:
     - BuybackVault reverts with `BUYBACK_ORACLE_REQUIRED`.
   - This is a _configuration error_, not a runtime fluke.

2. **Oracle is mandatory for PSM flows**

   - PSM cannot operate without an oracle:
     - Missing oracle ⇒ revert with `PSM_ORACLE_MISSING`.
   - There is **no 1e18 fallback** anymore.
   - All PSM flows (mint, redeem, price normalization, fees, spreads)
     depend on a configured oracle.

3. **Guardian flows are aligned with this truth**

   - `Guardian_PSMUnpause` now ensures that the PSM is unpaused into a state
     with a valid oracle configured.
   - Semantics:
     > “Unpause PSM” = “PSM is operational **with** oracle”.

4. **Reason codes are now “sharp”**

   - BuybackVault:
     - `BUYBACK_ORACLE_REQUIRED` (no oracle module while enforcement is on)
   - PSM:
     - `PSM_ORACLE_MISSING` (no oracle configured)

These codes are not optional; they are part of the protocol surface and must be
reflected in future DEV-11 tests, docs and governance playbooks.

---

## 3. DEV-11 scope: what changes in practice?

DEV-11 covers BuybackVault strategy, advanced tests and later phases of the
economic layer. Going forward, the following assumptions are **mandatory**:

### 3.1 BuybackVault: A02 Oracle Gate

- OracleRequired (A02) is a **hard precondition**:
  - No oracle module + enforcement enabled ⇒ `BUYBACK_ORACLE_REQUIRED`.
  - “No oracle” is not a tolerable degraded mode.
- When designing strategies or test scenarios:
  - A buyback that would otherwise be allowed must still revert if A02 fails.
  - Tests must explicitly cover:
    - _no module configured_ ⇒ `BUYBACK_ORACLE_REQUIRED`
    - _module unhealthy_ ⇒ `BUYBACK_ORACLE_UNHEALTHY`
    - _module healthy but window full_ (A03) ⇒ window-related revert

### 3.2 PSM: price & flow safety

- All DEV-11 work that uses the PSM (directly or indirectly via BuybackVault)
  must assume:
  - PSM cannot be used as a “dumb swap box” without oracle.
  - Any configuration without oracle is an **illegal protocol state**.
- Test harnesses must not re-introduce “oracle-optional” behavior.

### 3.3 StrategyEnforcement (Phase A/B/C)

Even though StrategyEnforcement is still in preview, it must obey OracleRequired:

- Strategy must **never** approve a buyback if:
  - Oracle is missing, or
  - Oracle health gate reports “unhealthy”.
- “No strategy configured” may revert with `NO_STRATEGY_CONFIGURED`.
- “No oracle available” must always revert with the dedicated oracle reason code,
  not with a generic strategy error.

---

## 4. Governance & configuration implications for DEV-11

For future governance docs, parameter playbooks and UI flows (owned by DEV-11
and related roles), the following configurations are **forbidden**:

- PSM enabled while oracle is unset.
- BuybackVault strict mode enabled while oracle health module is unset.
- Enforcement flags that would allow strategies to run when OracleRequired
  is not satisfied.

These situations must be treated as **invalid configurations**, not as
acceptable edge cases.

---

## 5. References

The following documents are the canonical sources for OracleRequired:

- `DEV49_OracleRequired_SafetyPlan_r1.md`
- `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`

DEV-11 work should reference these documents where appropriate and must not
attempt to weaken the guarantees specified there.
MD

# 2) Eintrag im REPORTS_INDEX ergänzen
python - << 'PY'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text(encoding="utf-8").splitlines()

entry = "- [DEV11_OracleRequired_Handshake_r1](DEV11_OracleRequired_Handshake_r1.md)"

# Duplikate vermeiden
if any("DEV11_OracleRequired_Handshake_r1" in line for line in text):
    raise SystemExit("entry already present, nothing to do")

# Versuche erst einen bestehenden DEV-11-Block zu finden
idx = None
for i, line in enumerate(text):
    if line.strip() == "## DEV-11":
        idx = i
        break

if idx is not None:
    insert_pos = idx + 1
    # Nachfolgenden Bullet-Block überspringen
    while insert_pos < len(text) and text[insert_pos].strip().startswith("- "):
        insert_pos += 1
    text.insert(insert_pos, entry)
else:
    # Kein DEV-11-Block vorhanden → neuen Abschnitt am Ende anlegen
    if text and text[-1].strip() != "":
        text.append("")
    text.append("## DEV-11")
    text.append("")
    text.append(entry)

path.write_text("\n".join(text) + "\n", encoding="utf-8")
PY

# 3) Log-Eintrag
echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired handshake report for DEV-11 and index it in REPORTS_INDEX" >> logs/project.log

echo "== DEV11 step01: OracleRequired handshake report created and indexed =="
