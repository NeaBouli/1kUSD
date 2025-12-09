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

DEV-9 introduced (or will introduce) a docs-only patch with the following intent:

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

Log target:  
`[DEV-9 40] ... Added oracle & safety architecture clarifications (docs-only)`

No CI, YAML, or contract changes are required for this patch.

---

## 4. Implications for future work

- **DEV-11 (Solidity track)**  
  Must treat these clarifications as **normative**.  
  A01–A03, oracle dependencies and reason codes (`BUYBACK_ORACLE_REQUIRED`,
  `PSM_ORACLE_MISSING`) are part of the canonical behaviour.

- **DEV-9 (future Infra/Docs work)**  
  Any new docs, integration guides or release notes must:
  - avoid "oracle-free" terminology,
  - clearly separate Phase A safety stack from StrategyEnforcement previews,
  - keep the PSM–BuybackVault–Oracle responsibilities clearly split.

- **DEV-94 (Release flow)**  
  Release checklists should include a human check that public messaging
  and docs reflect the above clarifications.

This sync is intended as a baseline for Co-Architect and future DEV blocks.
