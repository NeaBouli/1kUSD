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

\n\n## BuybackVault StrategyEnforcement – Phase 1 (v0.52.x Preview)

**Kurzfassung**

- Der BuybackVault wurde um eine optionale Policy-Schicht erweitert:
  - `StrategyConfig` (asset / weightBps / enabled) ist in v0.51.0 bereits
    als Konfigurations- und Telemetrie-Schicht vorhanden.
  - `strategiesEnforced` Flag (bool), steuerbar via `setStrategiesEnforced(bool)` (onlyDAO).
  - Fehlercodes: `NO_STRATEGY_CONFIGURED` und `NO_ENABLED_STRATEGY_FOR_ASSET`.
- Standardverhalten bleibt v0.51.0-kompatibel:
  - `strategiesEnforced` ist im Default `false`.
  - Solange das Flag nicht gesetzt wird, verhält sich `executeBuyback()` wie zuvor.

**Code-Status**

- Kernlogik:
  - Strategy-Storage: `StrategyConfig[] public strategies`.
  - Enforcement-Guard in `executeBuyback()`:
    - Wenn `strategiesEnforced == true`:
      - Revert mit `NO_STRATEGY_CONFIGURED`, falls `strategies.length == 0`.
      - Revert mit `NO_ENABLED_STRATEGY_FOR_ASSET`, falls keine aktivierte Strategie
        für das Ziel-Asset existiert.
    - Wenn `strategiesEnforced == false`:
      - Keine zusätzlichen Reverts, Verhalten entspricht v0.51.0.
  - Events:
    - `StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled)`
    - `StrategyEnforcementUpdated(bool enforced)`
- Tests:
  - `BuybackVaultTest` deckt die Basisflüsse (Funding, Withdraw, Execute).
  - `BuybackVaultStrategyGuardTest` prüft explizit:
    - Durchlauf ohne Enforcements (Backward-Compat).
    - Reverts bei aktivem Enforcement ohne Strategie / ohne aktivierte Strategie.
    - Erfolgreiche Buybacks bei aktivierter, gültiger Strategie.
- Interface:
  - `contracts/strategy/IBuybackStrategy.sol` ist als Forward-Layer definiert,
    wird aber in v0.51.x/0.52.x Phase 1 noch nicht produktiv eingebunden.

**Governance & Doku**

- Governance:
  - `docs/governance/parameter_playbook.md` enthält Abschnitte zu:
    - `StrategyConfig` (v0.51.0, vorbereitend).
    - `StrategyEnforcement (v0.52.x)` inkl. Bedienlogik und Rückfall in den
      „v0.51.0-Mode“ über `setStrategiesEnforced(false)`.
- Architektur:
  - `docs/architecture/buybackvault_strategy.md` – Überblick Strategy-Layer.
  - `docs/architecture/buybackvault_strategy_rfc.md` – RFC mit Optionen und
    Nichtzielen.
  - `docs/architecture/buybackvault_strategy_phase1.md` – Phase-1-Plan
    (optional Enforcement, Single-Asset-Guard).
  - `docs/architecture/economic_layer_overview.md` – Economic-Layer-Übersicht
    inkl. StrategyConfig-Note und StrategyEnforcement-Phase-1-Sektion.
- Indexer:
  - `docs/indexer/indexer_buybackvault.md` dokumentiert:
    - Mapping von `strategiesEnforced` und `StrategyEnforcementUpdated`.
    - Interpretation der Reverts `NO_STRATEGY_CONFIGURED` /
      `NO_ENABLED_STRATEGY_FOR_ASSET` als „policy-bedingt“ und nicht als
      Protokollfehler.

**Einschätzung / Release-Impact**

- v0.51.0 Baseline:
  - Bleibt vollständig gültig, solange `strategiesEnforced == false`.
  - Deployment kann mit aktivem Strategy-Layer, aber deaktiviertem Enforcement
    erfolgen, ohne die bisherigen Sicherheits- und Invarianten-Garantien zu brechen.
- v0.52.x Vorbereitung:
  - StrategyEnforcement-Mechanik ist vollständig implementiert und getestet.
  - Aktivierung des Flags ist eine Governance-/DAO-Entscheidung und sollte
    mit einem eigenen Parameter-Beschluss + Monitoring (Indexer-Dashboards)
    gekoppelt werden.
- Empfehlung:
  - Economic-Layer v0.51.0 als „stabile Basis“ führen.
  - StrategyEnforcement-Phase 1 als „opt-in“ Feature deklarieren, das erst
    nach separatem Governance-Beschluss produktiv aktiviert wird.
\n