# 1kUSD – Project Status Overview  
## Economic Layer v0.51.0 (EVM / Kasplex-compatible)

This document is a high-level status overview for the 1kUSD Economic Layer v0.51.0 and its surrounding build, security and governance context.  
It is intended for maintainers, auditors, infra engineers and governance participants.

Legend:

- 🟩 DONE / stable
- 🟦 OPEN / in progress
- 🟥 BLOCKED / needs attention

---

## 1. Economic Layer Core Status

### 1.1 Core Components

- 🟩 1kUSD core mechanics (mint/burn, basic accounting)  
- 🟩 Peg Stability Module v0.50.0 (PSM)  
- 🟩 Oracle stack (Aggregator + Watcher / health checks)  
- 🟩 Guardian / SafetyAutomata (pause, emergency controls)  
- 🟦 BuybackVault (Stages A–C implemented, further strategy work expected)  
- 🟦 StrategyConfig (scaffolded and wired, more governance work expected later)

The baseline for all security/risk documents is **Economic Layer v0.51.0** with **PSM v0.50.0** and the current Guardian/Oracle integration.

---

## 2. Security & Risk Layer (DEV-8 – DEV-80…89)

All work in this section is **documentation-only** and does **not** change runtime behaviour, CI, Docker or Pages.

### 2.1 New Documents (DEV-80…DEV-85)

- 🟩 `docs/security/audit_plan.md`  
  - Full audit plan for Economic Layer v0.51.0: scope, methodology, severity model, fix-waves and on-chain verification.

- 🟩 `docs/security/bug_bounty.md`  
  - Bug bounty specification with conservative, KAS-denominated rewards and responsible disclosure rules.

- 🟩 `docs/risk/proof_of_reserves_spec.md`  
  - Hybrid PoR design: on-chain view contract + 6h Merkle snapshots + public JSON reports.

- 🟩 `docs/risk/collateral_risk_profile.md`  
  - Qualitative risk assessment for:
    - USDT, USDC (primary),
    - WBTC, WETH / ETH (optional risk-on).

- 🟩 `docs/risk/emergency_depeg_runbook.md`  
  - Operational runbook for depeg scenarios (collateral, 1kUSD, systemic), including roles, actions and communication.

- 🟩 `docs/testing/stress_test_suite_plan.md`  
  - Stress test plan using Foundry, Echidna and Slither, with a focus on:
    - oracle lag,
    - PSM limit bypass,
    - Guardian abuse,
    - vault drain surfaces,
    - buyback misrouting.

### 2.2 Indexer & Governance (DEV-86…DEV-89)

- 🟩 `docs/indexer/indexer_buybackvault.md`  
  - Indexer & telemetry specification for BuybackVault and StrategyConfig:
    - DTOs, KPIs, error metrics,
    - reorg handling and DevOps monitoring.

- 🟩 `docs/reports/DEV87_Governance_Handover_v051.md`  
  - Technical governance handover for Economic Layer v0.51.0:
    - roles (Operator, Guardian, Governor, Risk Council),
    - governance-sensitive parameters,
    - operational flows.

- 🟩 `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`  
  - Sync report for DEV-7 (build/infra), confirming:
    - no changes to contracts/, CI, Docker, mkdocs.yml,
    - new docs under `docs/security/`, `docs/risk/`, `docs/testing/`, `docs/indexer/`, `docs/reports/`,
    - a new README section only.

### 2.3 README Integration

- 🟩 `README.md` – new **“Security & Risk”** section  
  - Placed directly below the Architecture section (or appended as fallback).  
  - Links:
    - audit plan,
    - bug bounty,
    - PoR spec,
    - collateral risk profile,
    - emergency depeg runbook,
    - stress test suite plan,
    - governance handover.

---

## 3. Build / Infra / Docker / CI / Pages (DEV-7)

DEV-7AAAAAAA remains owner of build, infra, Docker and Pages.

### 3.1 Current Status (high-level)

- 🟦 Docker & multi-arch builds (container images for 1kUSD stack)  
- 🟦 CI pipeline (Foundry tests, linting, docs checks)  
- 🟦 GitHub Pages / MkDocs routing & navigation  
- 🟦 Optional integration of new Security & Risk docs into navigation and CI

No DEV-8 work modified any of these areas.  
DEV-7 can continue independently, using:

- `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`  
  as the primary reference for the new documentation.

---

## 4. Governance & Risk Management View

From a governance perspective, v0.51.0 now has:

- 🟩 a structured **audit plan** (what auditors must cover),
- 🟩 a defined **bug bounty program** (what external researchers can expect),
- 🟩 a clear **PoR framework** (on-chain + off-chain),
- 🟩 a **collateral risk profile** (per asset),
- 🟩 a **depeg runbook** (how to react operationally),
- 🟩 a **stress test plan** (how to test what might fail),
- 🟩 a **governance handover** (who decides what),
- 🟩 and a **Dev7 sync report** (how infra relates to all this).

This provides a coherent baseline for:

- external auditors,
- future governance multisig,
- infra & monitoring setup,
- future releases (v0.52+).

---

## 5. Next Suggested Steps (Non-Binding)

These are recommended but NOT mandatory next steps:

1. **DEV-7 integration (optional)**  
   - Add the new Security & Risk docs to MkDocs navigation.  
   - Consider CI checks that ensure docs consistency.

2. **Audit & Bug Bounty preparation**  
   - Use `audit_plan.md` to prepare auditor scopes and timelines.  
   - Use `bug_bounty.md` as a basis for a public bug bounty announcement.

3. **Monitoring & Indexer onboarding**  
   - Implement the BuybackVault indexer as per `docs/indexer/indexer_buybackvault.md`.  
   - Attach metrics to Prometheus/Grafana dashboards.

4. **Governance onboarding**  
   - Share `DEV87_Governance_Handover_v051.md` with future Governors, Guardians, Operators and Risk Council members as onboarding material.

This document is a snapshot for **Economic Layer v0.51.0** and MUST be updated whenever major protocol, collateral or governance changes are introduced.

