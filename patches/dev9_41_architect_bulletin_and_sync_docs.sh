#!/bin/bash
set -e

echo "== DEV-9 41: add architecture sync + architect bulletin docs (docs-only) =="

mkdir -p docs/dev
mkdir -p docs/reports

# 1) DEV-9 Architecture Sync Doc
SYNC_FILE="docs/dev/DEV9_Architecture_Sync_OracleClarifications_r1.md"
if [ ! -f "$SYNC_FILE" ]; then
  cat <<'EOD' > "$SYNC_FILE"
# DEV-9 Architecture Sync – Oracle & Safety Clarifications (r1)

**From:** DEV-9 (Infra/Docs/CI)  
**To:** Architecture, DEV-11, Governance, Co-Architect  
**Repo:** NeaBouli/1kUSD (`main`)

---

## 1. Background

During an external AI-based summary of the 1kUSD project, several
misinterpretations surfaced regarding:

- the role of **oracles**,
- the status of the **BuybackVault safety layers** (Phase A),
- the relationship between **StrategyEnforcement preview** and
  the canonical safety stack.

These misunderstandings are now explicitly corrected in the internal
documentation so that future work (DEV-9, DEV-11, DEV-94, governance,
indexers) stays aligned with the true architecture.

---

## 2. Canonical clarifications (effective immediately)

1. **1kUSD is not oracle-free**

   - 1kUSD is deliberately **oracle-secured**.
   - Oracles are required for:
     - PSM pricing and limits,
     - BuybackVault health checks (A02),
     - guardian/safety signalling.
   - There is no supported "oracle-free PSM" mode.

2. **Phase A (A01–A03) is the canonical buyback safety stack**

   - A01: per-operation treasury cap = hard mandatory safety feature.
   - A02: oracle/health gate = configurable, but canonical for strict mode.
   - A03: rolling window cap = time-based aggregation layer.
   - StrategyEnforcement **preview** is separate and must not be confused
     with the Phase A safety stack.

3. **PSM always requires a price feed**

   - Stale/diff checks can be disabled; the **price feed itself cannot**.
   - Operating the PSM without a valid price feed is a configuration error,
     not a supported mode.

4. **OracleGate scope is BuybackVault-specific**

   - A02 governs buybacks only.
   - PSM and BuybackVault have separate (but related) oracle responsibilities
     and must not be merged conceptually.

5. **Multi-asset buybacks are Phase C (future), not Phase A/B**

   - Current implementation and docs remain **single-asset**.
   - Any multi-asset strategy belongs to a future phase and should not be
     assumed live.

---

## 3. Concrete doc changes by DEV-9 (DEV-9 40)

DEV-9 introduced a docs-only patch:

- `docs/architecture/economic_layer_overview.md`  
  → New section: **Oracle dependencies – architecture clarification (Dec 2025)**

- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`  
  → New reason codes:
  - `BUYBACK_ORACLE_REQUIRED`
  - `PSM_ORACLE_MISSING`

- `docs/integrations/buybackvault_observer_guide.md`  
  → New section: **OracleGate scope clarification (Dec 2025)**

- `docs/dev/DEV94_ReleaseFlow_Plan_r2.md`  
  → New section: **Release messaging guardrails – Oracle & safety stack**

Log:  
`[DEV-9 40] ... Added oracle & safety architecture clarifications (docs-only)`

No CI, YAML, or contract changes were made.

---

## 4. Implications for future work

- **DEV-11 (Solidity track)**  
  Must treat these clarifications as **normative**.  
  A01–A03, oracle dependencies and reason codes (`BUYBACK_ORACLE_REQUIRED`,
  `PSM_ORACLE_MISSING`) are now part of the canonical behaviour.

- **DEV-9 (future Infra/Docs work)**  
  Any new docs, integration guides or release notes must:
  - avoid "oracle-free" terminology,
  - clearly separate Phase A safety stack from StrategyEnforcement previews,
  - keep the PSM–BuybackVault–Oracle responsibilities clearly split.

- **DEV-94 (Release flow)**  
  Release checklists should include a human check that public messaging
  and docs reflect the above clarifications.

This sync is intended as a baseline for Co-Architect and future DEV blocks.
EOD
else
  echo "Sync doc already exists, not overwriting: $SYNC_FILE"
fi

# 2) Architect Bulletin Doc
BULLETIN_FILE="docs/reports/ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md"
if [ ! -f "$BULLETIN_FILE" ]; then
  cat <<'EOD' > "$BULLETIN_FILE"
# ARCHITECT BULLETIN – Oracle & Buyback Safety Clarifications (Dec 2025)

**Issued by:** Architecture (1kUSD Economic Layer & BuybackVault)  
**Audience:** Co-Architect, DEV-7/8/9/10/11, Governance, Indexer/Infra teams  
**Scope:** 1kUSD Economic Layer, PSM, BuybackVault Phase A (A01–A03)

---

## 1. Purpose

This bulletin codifies several clarifications about the 1kUSD architecture
that became necessary after external summaries introduced incorrect or
ambiguous statements.

These clarifications are **binding** for all future architecture, code,
documentation, governance and integration work.

---

## 2. Oracle dependency – canonical position

1. 1kUSD is **oracle-secured by design**. Oracles are not an optional
   add-on but an inherent part of:

   - the PegStabilityModule (PSM),
   - the BuybackVault safety gate (A02),
   - guardian and safety automata.

2. Disabling stale- or diff-checks for a given oracle does **not** mean
   the PSM can operate without a price feed.  
   A PSM without a valid price feed is considered a **configuration
   failure**, not a supported operating mode.

3. Future Kaspa-native deployments remain bound to this principle:
   removing oracle dependency entirely is **not** an architectural goal.
   Reducing oracle surface and failure modes is.

---

## 3. Buyback safety stack – Phase A is canonical

The canonical buyback safety stack consists of **Phase A** (DEV-11):

- **A01 – Per-operation treasury cap**  
  Hard cap, expressed in basis points of the treasury share dedicated to
  buybacks. Mandatory safety feature; can be effectively disabled only via
  configuration, not by changing semantics.

- **A02 – Oracle/Health gate**  
  Configurable safety layer that uses oracle/health signals and guardian
  policies to allow or block buybacks in strict modes.

- **A03 – Rolling window cap**  
  Time-based aggregation limit that prevents series of operations from
  exceeding a configured cap over a rolling window.

This stack is **authoritative** for buyback safety.  
StrategyEnforcement previews are **not** a replacement for Phase A.

---

## 4. StrategyEnforcement preview – limited role

1. StrategyEnforcement as introduced in preview form (v0.51.1 line) is an
   **optional, experimental layer**.

2. Its role is limited to making strategy definitions explicit and
   enforceable for certain flows. It does not define the baseline safety
   of the BuybackVault.

3. Phase A (A01–A03) has higher priority and must be treated as the
   reference for safety analysis, audits and governance decisions.

---

## 5. PSM vs. BuybackVault – oracle responsibilities

To avoid conceptual drift:

- The **PSM** is responsible for correct pricing and limits using oracles.
- The **BuybackVault** is responsible for safe treasury usage and
  buyback execution, informed by oracle/guardian signals (A02).

Consequences:

- New error/telemetry semantics are introduced:

  - `PSM_ORACLE_MISSING`  
    Indicates that the PSM is asked to operate without a valid price
    feed. This is a configuration error, not a valid operating mode.

  - `BUYBACK_ORACLE_REQUIRED`  
    Indicates that a strict buyback configuration expects oracle/health
    information but no valid module is present.

- Integrations, dashboards and indexers must treat these signals as
  **hard safety flags**, not as soft hints.

---

## 6. Multi-asset buybacks – not active in Phase A/B

1. Current implementations and docs reflect a **single-asset** view for
   BuybackVault (stable + asset).

2. Multi-asset/basket strategies, DEX-routing and similar features belong
   to a potential **Phase C** and are not part of the deployed v0.51.x
   behaviour or the completed Phase A/B work.

3. Any document or roadmap that refers to "multi-asset strategies" must
   clearly label them as **future, not yet implemented**.

---

## 7. Release & messaging guardrails

To prevent misaligned external expectations:

1. No release, announcement or documentation may claim that 1kUSD is
   "oracle-free" or that oracles are optional.

2. Public materials must:

   - describe Phase A (A01–A03) as the **canonical** buyback safety stack,
   - clearly label StrategyEnforcement functionality as "preview" or
     "advanced" and **not** as the safety baseline.

3. Release processes (DEV-94) should include a **human review step** that
   checks:

   - consistency of docs with this bulletin,
   - absence of "oracle-free" language,
   - correct description of PSM/BuybackVault/Oracle responsibilities.

---

## 8. Action items

- **DEV-9**

  - Has implemented an initial docs-only clarification patch (DEV-9 40).
  - Future Infra/Docs changes must be checked against this bulletin.

- **DEV-11**

  - Must treat these clarifications as **normative assumptions** when
    extending BuybackVault and the economic layer.
  - Telemetry, invariants and tests must encode the oracle dependency
    explicitly.

- **Governance & Risk**

  - Governance playbooks and risk reports should be updated (where
    appropriate) to mention Phase A as the canonical safety stack and to
    reflect the mandatory nature of oracle dependency.

This bulletin remains in force until superseded by a later architecture
decision.
EOD
else
  echo "Bulletin doc already exists, not overwriting: $BULLETIN_FILE"
fi

# 3) Link sync + bulletin in docs/INDEX.md if present
INDEX_FILE="docs/INDEX.md"
if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "DEV9_Architecture_Sync_OracleClarifications_r1" "$INDEX_FILE"; then
    cat <<'EOD' >> "$INDEX_FILE"

- [DEV9_Architecture_Sync_OracleClarifications_r1](dev/DEV9_Architecture_Sync_OracleClarifications_r1.md) – DEV-9 architecture sync on oracle & safety clarifications (Dec 2025).
EOD
  else
    echo "docs/INDEX.md already links DEV9 architecture sync."
  fi

  if ! grep -q "ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12" "$INDEX_FILE"; then
    cat <<'EOD' >> "$INDEX_FILE"

- [ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12](reports/ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md) – Architect bulletin on oracle dependency & buyback safety stack (Dec 2025).
EOD
  else
    echo "docs/INDEX.md already links architect bulletin."
  fi
else
  echo "WARNING: $INDEX_FILE not found, skipping docs/INDEX.md links."
fi

# 4) Link bulletin in REPORTS_INDEX if present
REPORTS_INDEX="docs/reports/REPORTS_INDEX.md"
if [ -f "$REPORTS_INDEX" ]; then
  if ! grep -q "ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12" "$REPORTS_INDEX"; then
    cat <<'EOD' >> "$REPORTS_INDEX"

- [ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12](ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md) – Oracle & buyback safety clarifications (architect bulletin, Dec 2025).
EOD
  else
    echo "REPORTS_INDEX already links architect bulletin."
  fi
else
  echo "WARNING: $REPORTS_INDEX not found, skipping reports index link."
fi

# 5) Log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 41] ${timestamp} Added DEV-9 architecture sync and architect bulletin docs (docs-only)" >> "$LOG_FILE"

echo "== DEV-9 41 done =="
