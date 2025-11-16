!!! success "Latest: DEV-40 — OracleWatcher & Interface Recovery"
    - [Release Report](reports/DEV40_RELEASE_REPORT.md)
    - [Phase 2 Report](reports/DEV40_PHASE2_REPORT.md)
    - [Architect Handoff](reports/DEV40_ARCHITECT_HANDOFF.md)


# 🪙 1kUSD Stablecoin Protocol

Welcome to the **1kUSD Documentation Portal**.

This site provides:
- 📘 Technical specifications (`specs/`)
- ⚙️ Smart contract architecture (`contracts/core/`)
- 🧠 Governance and safety modules (`safety/`)
- 💡 Integration guides and testing notes (`integrations/`, `testing/`)

For the full GitHub repository, visit:
👉 [NeaBouli/1kUSD](https://github.com/NeaBouli/1kUSD)


---

## DEV-41 — Oracle Regression Stability

- **Report:** `docs/reports/DEV41_ORACLE_REGRESSION.md`  
- Scope: OracleWatcher regression, OracleAggregator wiring, ZERO_ADDRESS root-cause analysis, refreshState behavior alignment, all oracle-related tests green.


---

## 🔵 DEV-42 — Oracle Aggregation Consolidation
**Goal:** Finalize Oracle module separation, cleanup, consolidation, and regression safety.

### Completed:
- Removed obsolete *.bak Solidity sources
- Unified IOracleAggregator struct bindings
- Confirmed single-source-of-truth for getPrice()
- Rebuilt OracleWatcher interaction model
- Ran targeted suites:
  - OracleRegression_Watcher (pass)
  - OracleRegression_Base (pass)
  - Guardian_OraclePropagation (pass)
  - Guardian_Integration (pass)

System is stable and fully aligned with v0.42 architecture.

---

## 🔵 DEV-43 — PSM Consolidation & Safety Wiring

**Ziel:** Den Peg Stability Module (PSM) von einer losen Sammlung von Komponenten zu einer klar definierten, audit-fähigen Fassade zu konsolidieren.

**Kernpunkte:**
- `PegStabilityModule` als kanonischer IPSM-Entry-Point, der PSMSwapCore, PSMLimits, SafetyAutomata und Oracle bündelt.
- Verpflichtendes Safety-Gate (`MODULE_PSM`) für alle Swap-Einstiegspunkte.
- Limits-Enforcement über `PSMLimits.checkAndUpdate(...)` im PSM-Swap-Pfad.
- Umstellung von FeeRouter-V2-Zugriff auf IFeeRouterV2 Interface (keine low-level calls mehr).
- Oracle-Health-Stubs im PSM (Preislogik folgt in DEV-44/45).
- Neue PSM-Regression-Skelette zur Vorbereitung erweiterter Tests.

Systemstatus: **stabil**, alle relevanten Tests grün, PSM-Schicht architektonisch konsolidiert und bereit für ökonomische Logik in den nächsten DEV-Schritten.

---

## 🔵 DEV-44 — PSM Price Normalization & Limits Math

**Status:** Price-Math-Schicht abgeschlossen, Asset-Flows folgen in DEV-45.

**Kurzfassung:**
- PSM-Swaps und Quotes laufen über preis-normalisierte 1kUSD-Notionals (18 Decimals).
- PSMLimits werden auf diesen stabilen Notional-Beträgen durchgesetzt.
- Oracle wird über `IOracleAggregator` eingebunden; Health-Gates und einfache Fallback-Logik sind vorhanden.
- Asset-Flows (Vault, echte ERC-20 Transfers, 1kUSD Mint/Burn) bleiben bewusst deaktiviert und werden in DEV-45 implementiert.

Für Details siehe: `docs/reports/DEV44_PSM_PRICE_NORMALIZATION.md`.
