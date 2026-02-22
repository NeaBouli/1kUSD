# 🧭 Projektstatus: 1kUSD – Kaspa Stablecoin

Letztes Update: **$(date '+%Y-%m-%d %H:%M:%S')**

---

## 📦 Build & CI Status

| Workflow | Status | Beschreibung |
|-----------|:------:|--------------|
| **Foundry Tests** | 🟢 **Bestanden** | Alle Solidity-Tests erfolgreich durchgelaufen |
| **Solidity CI** | 🟢 **Bestanden** | Linting, Syntax und Kompilierung fehlerfrei |
| **Docs Deploy** | 🟢 **Online** | GitHub Pages Deployment aktiv unter: [neabouli.github.io/1kUSD](https://neabouli.github.io/1kUSD) |

---

## ⚙️ Core Module Übersicht

📦 contracts/core
├── 🟢 SafetyAutomata.sol → Modul-basiertes Pausensystem (per-module mapping, ✅ getestet)
├── 🟢 PegStabilityModule.sol → PSM-Logik für Swaps 1kUSD ↔ Collateral
├── 🟢 CollateralVault.sol → Verwaltung und Accounting von Collateral-Assets
├── 🟢 OracleAggregator.sol → Preis- und Feed-Aggregation für PSM / Vault
├── 🟢 ParameterRegistry.sol → Zentrale Governance-Parameter (Fees, Limits)
└── 🟢 DAO_Timelock.sol → Zeitverzögerte Governance-Aktionen

yaml
Code kopieren

---

## 🧪 Testübersicht (Foundry)

- `TestSafetyNet.t.sol` ✅  
- `TestGuardianMonitor.t.sol` ✅  
- `MockOracleAggregator.sol` ✅  
- `MockSafetyAutomata.sol` ✅  

---

## 🧱 Nächste Schritte

1. 🟦 **Refactor:** Konsistente MixedCase-Benennung (Lint-Hinweise aus Forge-Lint).
2. 🟦 **Docs:** `index.md` Fehler beheben → Hauptdokument fehlt im `nav`.
3. 🟩 **Optional:** `foundry.toml` erweitern um Compiler-Optimierung (`optimizer_runs = 20000`).
4. 🟢 **CI-Ready:** Pipeline voll funktionsfähig – kann als Template für zukünftige Module verwendet werden.

---

✅ **Gesamtstatus:**  
> Das Projekt ist **build-stabil, test-grün und dokumentiert**.  
> Alle OpenZeppelin-Imports werden korrekt aufgelöst, CI-Kette läuft automatisch durch.


---

| DEV-41 | Oracle Regression Stability | Completed | v0.41.x | ✓ All tests green |

- **Status:** ✅ Completed  
- **Scope:**  
  - Fix ZERO_ADDRESS() reverts in oracle regression tests  
  - Normalize OracleAggregator constructor usage (admin, safety, registry)  
  - Clean inheritance and field ownership between OracleRegression_Base and OracleRegression_Watcher  
  - Align `refreshState()` regression test with actual health update semantics  
- **Report:** `docs/reports/DEV41_ORACLE_REGRESSION.md`


## DEV-42 — Oracle Aggregation Consolidation (2025-11-14)
- Removed all legacy *.bak contract sources
- Normalized getPrice() interface
- Clean OracleAggregator ↔ OracleWatcher separation
- Regression test suites fully green
- Guardian pause/resume path verified

## DEV-43 — PSM Consolidation & Safety Wiring (2025-11-14)
- PegStabilityModule als kanonische IPSM-Fassade neu strukturiert
- SafetyAutomata-Gate (MODULE_PSM) für Swaps aktiviert
- PSMLimits in den Swap-Pfad integriert (Stub-Notional, Mathe folgt in DEV-44)
- Oracle-Health-Gate im PSM verdrahtet (ohne Preisberechnung)
- PSMSwapCore nutzt nun IFeeRouterV2-Interface statt low-level call
- Neue PSM-Regression-Skelette unter foundry/test/psm/ angelegt

## DEV-44 — PSM Price Normalization ## DEV-44 — PSM Price Normalization & Limits Math (planned) Limits Math (price math complete, flows follow in DEV-45)
- Implement real price conversion for swapTo1kUSD / swapFrom1kUSD
- Normalize decimals between collateral assets and 1kUSD
- Enforce PSMLimits on stable notional amounts
- Extend PSM regression tests for price and limits behaviour

## DEV-45 — PSM Asset Flows & Fee Routing (planned)
- Wire PegStabilityModule to CollateralVault and OneKUSD (mint/burn).
- Implement asymmetrical fees on mint/redeem paths (1kUSD-notional basis).
- Route fees via FeeRouterV2 / IFeeRouterV2.
- Keep collateral asset pluggable to support future KAS / KRC-20 migration.
