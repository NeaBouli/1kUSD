#!/usr/bin/env bash
set -euo pipefail

# DEV-12 step03:
# - Add dedicated Oracle & PSM governance doc (v0.51)
# - Wire it into docs/governance/index.md
# - Log the change in logs/project.log

# 1) Governance-Dokument anlegen/überschreiben
python - << 'PY'
from pathlib import Path

path = Path("docs/governance/GOV_Oracle_PSM_Governance_v051_r1.md")

content = """# Oracle & PSM Governance (v0.51)

**Status:** draft r1 (DEV-12)  
**Scope:** governance requirements for Oracle, PegStabilityModule (PSM) and
BuybackVault strict mode under the OracleRequired semantics introduced by
DEV-49 / DEV-11 / DEV-87.

This document is written for **governance participants**, **operators** and
**auditors** who need a concise view on:

- what is *allowed* and *forbidden* in terms of Oracle configuration,
- how OracleRequired affects PSM and BuybackVault safety,
- which changes must be treated as high-risk governance actions.

It does **not** replace the detailed architecture reports; instead, it
summarises their governance-facing implications.

---

## 1. Background & references

This document builds on:

- **DEV-49 – OracleRequired implementation**
  - PSM now has *no* 1e18 fallback.
  - Missing Oracle → `PSM_ORACLE_MISSING` revert.
- **DEV-11 – Buyback safety and telemetry**
  - BuybackVault strict mode requires a configured Oracle health module
    when the gate is enforced.
  - Missing/invalid config → `BUYBACK_ORACLE_REQUIRED` revert.
- **DEV-87 – Governance handover v0.51**
  - Oracles are no longer optional; they are a **constitutional** part of
    the protocol, not a plug-in.
- **DEV-9 block & architect reports**
  - OracleRequired is treated as a *root safety layer* across PSM,
    BuybackVault and Guardian.

For technical and historical detail, see:

- `ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
- `ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md`
- `DEV11_OracleRequired_Handshake_r1.md`
- `BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md`

---

## 2. Governance principles for OracleRequired

### 2.1 No oracle-free operation

**Principle:** There is *no* legitimate configuration where core flows
operate without an Oracle.

- **PSM without Oracle**
  - PSM swaps must **not** execute when no Oracle is configured.
  - Expected behaviour:
    - Revert with `PSM_ORACLE_MISSING`.
    - Telemetry and operator dashboards must treat this as a **hard stop**.

- **BuybackVault strict mode without health module**
  - When `oracleHealthGateEnforced == true`, a missing health module is
    an *illegal* governance state.
  - Expected behaviour:
    - Revert with `BUYBACK_ORACLE_REQUIRED` for any buyback.
    - Ops dashboards must highlight this as a blocking misconfiguration.

Governance must **never** attempt to “temporarily bypass” these checks by
removing or blanking Oracle configuration.

### 2.2 No silent degradation

- There must be **no** mode where:
  - swaps or buybacks silently continue, **and**
  - telemetry shows “healthy/ok”, **while**
  - OracleRequired conditions are actually violated.

- Any attempt to create “fallback modes” (e.g. hard-coded prices, manual
  override of Oracle health) is considered an **architectural breach** and
  must not be merged or deployed without an explicit exception process.

### 2.3 Legacy profiles only with valid Oracle

“Legacy” or compatibility profiles (e.g. lower safety thresholds, reduced
gating) are only allowed when:

- a valid Oracle exists, **and**
- governance explicitly documents why a weaker profile is safe enough for
  the current deployment scenario.

Configuration patterns such as:

- “No Oracle + legacy profile”, or
- “Removed health gate to keep swaps running”

are **illegal** governance states and must be rejected at review time.

---

## 3. Roles & responsibilities

### 3.1 DAO / Governance

- Owns the **high-level Oracle policy**:
  - Which price feeds are used,
  - What safety margins (stale time, diff thresholds) are acceptable,
  - Under which conditions Oracle or gate parameters may be changed.
- Must ensure that:
  - Any config change that can affect OracleRequired is covered by:
    - a governance proposal,
    - a clear motivation,
    - an impact assessment on PSM and BuybackVault safety.
- Is responsible for **rolling back** unsafe Oracle changes if an incident
  or misconfiguration is detected.

### 3.2 Guardian / Safety layer

- Enforces pause/unpause decisions based on:
  - Oracle health,
  - system-wide incidents,
  - explicit emergency triggers.
- Must treat:
  - `PSM_ORACLE_MISSING` and `BUYBACK_ORACLE_REQUIRED` as **first-class** signals:
    - They require operator attention,
    - They may justify pausing additional components until fixed.
- Ensures that emergency playbooks include:
  - Procedures for restoring a valid Oracle configuration,
  - Coordination steps with Oracle operators and governance.

### 3.3 Oracle operators

- Maintain the underlying price feeds (nodes, adapter configs, etc.).
- Must:
  - Monitor Oracle health metrics (stale, diff, connectivity),
  - Report anomalies to governance and Guardian operators,
  - Avoid unilateral changes that can affect safety assumptions.

---

## 4. Configuration boundaries

### 4.1 PSM

Allowed configurations:

- Valid Oracle address set in the registry.
- Oracle parameters (stale time, diff thresholds) within documented
  safe ranges.
- PSM swap parameters (caps, spreads, fees) configured independently of
  OracleRequired, but **never** as substitutes for missing Oracle safety.

Forbidden configurations:

- Oracle address set to `address(0)` while PSM is active.
- “Placeholder” Oracle contracts that always return 1.0 without real data.
- On-chain hacks that hard-code prices or bypass Oracle checks.

### 4.2 BuybackVault strict mode

Allowed configurations:

- `oracleHealthGateEnforced == false`, with:
  - explicit rationale in governance docs,
  - clear plan for enabling the gate later.
- `oracleHealthGateEnforced == true` **with** a valid health module and
  safe parameters.

Forbidden configurations:

- `oracleHealthGateEnforced == true` **and** health module unset.
- Health modules that do not actually implement the documented guard
  semantics (e.g. always “healthy” modules).

### 4.3 Change management

Any proposal that changes:

- Oracle contracts or adapters,
- Oracle parameters (stale, diff, scaling),
- PSM Oracle configuration,
- BuybackVault Oracle health gate parameters,

must include:

1. **Motivation:** why the change is needed.
2. **Risk analysis:** what could go wrong if the change is wrong.
3. **Rollback plan:** how to revert quickly if unexpected behaviour is
   observed.

---

## 5. Reason codes & telemetry

The following reason codes are **mandatory anchors** for telemetry and
operator dashboards:

- `PSM_ORACLE_MISSING`
  - Signals that PSM is blocked because no valid Oracle is configured.
- `BUYBACK_ORACLE_REQUIRED`
  - Signals that BuybackVault strict mode rejects operations due to
    missing/invalid Oracle gate configuration.

Governance requirements:

- Dashboards must show these codes clearly (not hidden in debug logs).
- Operator runbooks must:
  - Contain a section “How to respond to OracleRequired reason codes”.
  - Describe who to contact and which configs to check.
- Incidents related to these codes must be logged as governance-relevant
  events (e.g. post-mortem summaries, governance notes).

---

## 6. Interaction with releases (DEV-94)

For every tagged release (v0.51.x and later), release managers must:

- Verify that:
  - PSM Oracle config is present and valid,
  - BuybackVault Oracle gate parameters are consistent with the intended
    deployment profile.
- Ensure that:
  - Release notes reference any Oracle-related changes,
  - Operators know which Oracle and gate configuration is *expected*.

If these conditions are not met, **release tagging should be blocked** until
the governance and Oracle configuration is clarified.

---

## 7. Non-goals / out of scope

This document does **not**:

- Define the exact technical interfaces of Oracle contracts.
- Specify the full architecture of the Oracle aggregator or watchers.
- Change any Solidity contracts or tests.
- Replace detailed incident runbooks.

It is a **governance-facing summary**: what is allowed, what is forbidden,
and which signals must be treated as critical when operating the protocol.
"""

path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(content, encoding="utf-8")
PY

# 2) Eintrag in docs/governance/index.md ergänzen
python - << 'PY'
from pathlib import Path

path = Path("docs/governance/index.md")
text = path.read_text(encoding="utf-8").splitlines()

entry = "- [GOV: Oracle & PSM governance (v0.51)](GOV_Oracle_PSM_Governance_v051_r1.md)"

# Wenn der Eintrag schon existiert → nichts tun
if any("GOV_Oracle_PSM_Governance_v051_r1.md" in line for line in text):
    raise SystemExit("entry already present, nothing to do")

# Versuchen, den bestehenden DEV-12-Plan-Eintrag zu finden
plan_idx = None
for i, line in enumerate(text):
    if "DEV12_Governance_Docs_Plan_r1" in line:
        plan_idx = i
        break

if plan_idx is not None:
    # Direkt unter dem Plan-Eintrag einfügen
    text.insert(plan_idx + 1, entry)
else:
    # Kein DEV-12-Plan gefunden → eigenen kleinen Abschnitt am Ende anlegen
    if text and text[-1].strip() != "":
        text.append("")
    text.append("## DEV-12 governance docs (outline & references)")
    text.append("")
    # Wir kennen den exakten Plan-Text nicht, daher nur der neue Eintrag hier
    text.append(entry)

path.write_text("\n".join(text) + "\n", encoding="utf-8")
PY

# 3) Log-Eintrag
echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add Oracle & PSM governance doc (v0.51) and link from governance index" >> logs/project.log

echo "== DEV-12 step03: Oracle & PSM governance doc added and indexed =="
