#!/usr/bin/env bash
set -euo pipefail

FILE="docs/reports/DEV60-72_BuybackVault_EconomicLayer.md"
LOG_FILE="logs/project.log"

echo "== DEV73 REP01: write DEV60-72 BuybackVault + Economic Layer handover report =="

mkdir -p "$(dirname "$FILE")"

cat <<'MD' > "$FILE"
# DEV-60…DEV-72 — BuybackVault & Economic Layer Handover

## 1. Scope & Ziele

Dieser Report fasst die Arbeiten von **DEV-60 bis DEV-72** rund um den
**BuybackVault** und den **Economic Layer** (PSM + Oracles) zusammen.

Ziele:

- BuybackVault als eigenständiges Modul des Economic Layers etablieren.
- PSM-basierte Buybacks aus Überschuss-1kUSD ermöglichen.
- Guardian/Safety-Pause sauber in das Modul integrieren.
- Telemetrie- und Governance-Pfad dokumentieren.
- Forward-Design für Strategien (`StrategyConfig`, `IBuybackStrategy`) anlegen,
  ohne das v0.51.0-Verhalten zu verändern.

---

## 2. BuybackVault — Core Implementierung (Stage A–C)

### 2.1 Contract

**Datei:** `contracts/core/BuybackVault.sol`

Kernmerkmale:

- Verwaltete Assets:
  - `asset`  – Ziel-Asset des Buybacks (z. B. Governance-Token).
  - `stable` – 1kUSD-Stablecoin.
- Rollen:
  - `dao`    – einzige Instanz für Funding, Withdrawals und Buybacks.
  - `safety` – Guardian/Safety-Layer, der über `moduleId` pausieren kann.
- Guardian-Integration:
  - `bytes32 public moduleId;`
  - `if (safety.isPaused(moduleId)) revert PAUSED();`

Fehler:

- `NOT_DAO()`, `ZERO_ADDRESS()`, `INVALID_AMOUNT()`,
  `INSUFFICIENT_BALANCE()`, `PAUSED()`.

Events:

- `StableFunded(address indexed from, uint256 amount);`
- `StableWithdrawn(address indexed to, uint256 amount);`
- `AssetWithdrawn(address indexed to, uint256 amount);`
- `BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);`

### 2.2 Funktionen

- **Fund / Withdraw:**
  - `fundStable(uint256 amount)` – DAO-only, 1kUSD in den Vault einzahlen.
  - `withdrawStable(address to, uint256 amount)` – DAO-only.
  - `withdrawAsset(address to, uint256 amount)` – DAO-only.
- **Buyback:**
  - `executeBuyback(address recipient, uint256 amountStable, uint256 minAssetOut, uint256 deadline)`
    - Nur `dao`.
    - Prüfungen:
      - `recipient != address(0)`
      - `amountStable > 0`
      - `!safety.isPaused(moduleId)`
      - ausreichender Stable-Kontostand.
    - Ablauf:
      - `stable.approve(address(psm), amountStable);`
      - `psm.swapFrom1kUSD(address(asset), amountStable, recipient, minAssetOut, deadline);`
      - `emit BuybackExecuted(recipient, amountStable, assetOut);`

---

## 3. Tests & Regression Suites

**Datei:** `foundry/test/BuybackVault.t.sol`

Abgedeckte Pfade (Auszug):

- Konstruktor-Guards:
  - Zero-Adresse für `asset`, `dao`, `psm`, `safety`, `stable` → revert.
- Funding:
  - `testFundStableOnlyDaoCanCall()`
  - `testFundStableRevertsWhenPaused()`
  - `testFundStableEmitsEvent()`
- Withdrawals:
  - `testWithdrawStableOnlyDao()`
  - `testWithdrawStableZeroAddressReverts()`
  - `testWithdrawStableEmitsEvent()`
  - `testWithdrawAssetOnlyDao()`
  - `testWithdrawAssetZeroAddressReverts()`
  - `testWithdrawAssetEmitsEvent()`
- Buyback:
  - `testExecuteBuybackOnlyDaoCanCall()`
  - `testExecuteBuybackRevertsWhenPaused()`
  - `testExecuteBuybackZeroAmountReverts()`
  - `testExecuteBuybackZeroRecipientReverts()`
  - `testExecuteBuybackTransfersStableAndMintsAsset()`
  - `testExecuteBuybackEmitsEvent()`
- Views:
  - `testBalanceViewsReflectHoldings()`

Event-Tests verwenden **topics-only Expectations** (keine strikte Prüfung der
Daten-Payload), um Änderungen an genauen Beträgen/Gasflows nicht unnötig
zu brechen.

Alle BuybackVault-Tests liegen grün; vollständiger Run:

- `forge test -vv --match-contract BuybackVaultTest`
  - 25/25 Tests **PASS**.

---

## 4. Economic Layer Integration

### 4.1 PSM & Oracle Baseline

Baseline ist in folgenden Releases dokumentiert:

- `docs/releases/v0.50.0_economic-layer.md`
  - PSM + Oracle Konsolidierung.
- `docs/releases/v0.51.0_buybackvault.md`
  - BuybackVault Stage A–C (PSM Execution, Events, Telemetrie).

Weitere Architekturdokumente:

- `docs/architecture/psm_parameters.md`
- `docs/architecture/psm_flows_invariants.md`
- `docs/specs/PSM_LIMITS_AND_INVARIANTS.md`
- `docs/specs/PSM_SWAP_CORE_FLOW.md`
- `docs/specs/VAULT_PSM_SETTLEMENT.md`
- `docs/specs/VAULT_WITHDRAW_RULES.md`

### 4.2 Economic Layer Overview

**Datei:** `docs/architecture/economic_layer_overview.md`

Inhalt (vereinfacht):

- Oracles + Guardian Watcher.
- PSM (PegStabilityModule) + Limits & Fees.
- BuybackVault (Funding, Buyback, Withdrawals).
- Telemetrie-Flows (Events → Indexer → Monitoring).

BuybackVault ist dort als eigenständige „Economic Layer-Komponente“
beschrieben, inkl.:

- Funding/Withdraw-Flows.
- PSM-basierter Buyback-Pfad.
- Guardian-Pause über `moduleId`.

---

## 5. Telemetrie & Indexer-Anbindung

BuybackVault ist bewusst **event-zentriert** gestaltet:

- `StableFunded`, `StableWithdrawn`, `AssetWithdrawn`,
  `BuybackExecuted` dienen als Primärquelle für:
  - Treasury-Monitoring.
  - Buyback-Analyse (Zeitreihen der Volumina).
  - Governance-Berichte.

Relevante Dokumente:

- `docs/indexer/INDEXING_TELEMETRY.md`
- BuybackVault-Abschnitt im `README.md`
  (Verlinkung zur Indexer/Telemetry-Spec).

Die Events werden in das bestehende Event-/DTO-Schema integrierbar gehalten.

---

## 6. Governance & Parameter

BuybackVault-relevante Governance-Docs:

- `docs/governance/parameter_playbook.md`
- `docs/governance/parameter_howto.md`

Dort ist u. a. dokumentiert:

- Welche Rollen Parameter/Module verändern dürfen (DAO-only).
- Wie BuybackVault-Strategie-Parameter (siehe StrategyConfig) im
  Governance-Prozess erfasst und versioniert werden sollen.

---

## 7. StrategyConfig & IBuybackStrategy (Forward Design)

### 7.1 StrategyConfig (v0.51.0)

**Implementierung:**

- `struct StrategyConfig {`
  - `address asset;`
  - `uint16 weightBps;`
  - `bool enabled;`
- `StrategyConfig[] public strategies;`
- `function strategyCount() external view returns (uint256);`
- `function getStrategy(uint256 id) external view returns (StrategyConfig memory);`
- `function setStrategy(uint256 id, address asset_, uint16 weightBps_, bool enabled_);`

Fehler & Events:

- `error INVALID_STRATEGY();`
- `event StrategyUpdated(uint256 indexed id, address indexed asset, uint16 weightBps, bool enabled);`

Tests:

- `testGetStrategyOutOfRangeReverts()`
- `testSetStrategyCreateAndUpdate()`
- `testSetStrategyInvalidIdReverts()`
- `testSetStrategyOnlyDao()`

**Wichtig:** In **v0.51.0** beeinflusst `StrategyConfig` das Verhalten von
`executeBuyback()` noch **nicht**. Es handelt sich um eine reine
Konfigurations- und Telemetrie-Schicht als Vorbereitung für Multi-Asset-
und Policy-basierte Buybacks in v0.52+.

Dokumentation:

- `docs/architecture/buybackvault_strategy.md`
- StrategyConfig-Hinweise in `economic_layer_overview.md`
- Governance-Snippet in `parameter_playbook.md`

### 7.2 IBuybackStrategy Interface

**Datei:** `contracts/strategy/IBuybackStrategy.sol`

Zweck:

- Deklariert ein **forward-looking Interface** für externe Strategie-Module,
  die künftig Buyback-Allokationen/Policies kapseln können.
- In v0.51.0 ist das Interface **noch nicht** an `BuybackVault` angehängt
  und dient als Design-Anchor für v0.52+.

Dokumentation:

- Abschnitt in `docs/architecture/buybackvault_strategy.md`
- Erwähnung in `docs/architecture/economic_layer_overview.md`

---

## 8. Zusammenfassung für den Lead-Dev

**Status v0.51.0:**

- BuybackVault ist voll in den Economic Layer integriert:
  - DAO-gesteuertes Funding + Withdrawals.
  - PSM-basierter Buyback-Pfad mit Guardian-Pause.
  - Vollständig getestete, deterministische Core-Flows.
- Events sind konsistent implementiert und test-abgedeckt.
- Telemetrie- und Governance-Pfad sind dokumentiert und in `README.md`,
  Architecture-Docs und Governance-Docs verlinkt.
- StrategyConfig + IBuybackStrategy sind als **non-intrusive Forward-Design**
  vorhanden (keine Verhaltensänderung).

**Release-Ausrichtung:**

- v0.50.0 – Economic Layer Basis (PSM + Oracles).
- v0.51.0 – BuybackVault Stage A–C + StrategyConfig (ohne Behaviour-Änderung).

**Empfohlene nächste Schritte (v0.52+):**

1. Auswahl eines ersten einfachen Strategy-Modells (z. B. Single-Asset,
   fester Weight, optionaler Daily-Cap).
2. Entwurf eines minimalen Strategy-Moduls auf Basis von `IBuybackStrategy`.
3. Erweiterung von BuybackVault, um optional Strategien zu verwenden
   (Feature-Flag / Version-Guard).
4. Ergänzende Indexer- und Governance-Dokumentation (Parameter-Schema,
   Rollback-Pfad, Migrationspfad).

MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-73] ${timestamp} Report: DEV-60..DEV-72 BuybackVault + Economic Layer handover written to ${FILE}." >> "$LOG_FILE"
echo "✓ Handover report written to $FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV73 REP01: done =="
