#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/buybackvault_execution.md"

echo "== DEV64 DOC01: write BuybackVault Execution Plan (Stage B/C) =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# BuybackVault Execution Plan (Stage B / C)

Status:  
- **Stage A** (Custody + DAO-only Funding/Withdrawals + Pause-Hooks) ist implementiert:
  - Contract: `contracts/core/BuybackVault.sol`
  - Tests: `foundry/test/BuybackVault.t.sol`
  - Gedeckt:
    - Konstruktor-Guards (kein Zero-Address für Stable/Asset/DAO/Safety)
    - `fundStable` nur durch DAO, pausierbar via Safety-Modul
    - `withdrawStable` / `withdrawAsset` nur durch DAO, Zero-Address-Schutz
    - View-Helper `stableBalance()` / `assetBalance()`

Dieses Dokument beschreibt die **nächsten Ausbaustufen (Stage B/C)**, ohne dass der aktuelle, stabile Stand verändert wird.

---

## 1. Zielbild: Rolle des BuybackVault

Der BuybackVault ist das **kapitaltragende Modul** für:

- **Rückkäufe / Burn von 1kUSD** (oder Treasury-Token) mit Stable-Überschüssen  
- **Recycling von Überschuss-Collateral** (optional, spätere Ausbaustufe)  
- **Parametrisierbare Ausführung** über Governance (DAO / Risk Council)

Er steht **zwischen**:

- Treasury / DAO (entscheidet *ob* und *wie viel* Stable in Rückkäufe fließt)  
- PSM / DEX / externe Routen (entscheidet *wie* die Ausführung on-chain passiert)

Stage B fokussiert auf einen **minimalen, nachvollziehbaren Execution-Flow**, der sich an der bestehenden **Economic Layer (PSM + OracleHealth)** orientiert.

---

## 2. Stage B – Minimaler Execution-Flow

### 2.1. High-Level-Flow

**Ziel:** Stable-Balance im BuybackVault in Richtung eines Zielassets (z. B. Governance-Token oder 1kUSD) bewegen, ohne das Safety-/PSM-Modell zu brechen.

Minimaler Flow (Canonical Path):

1. **DAO beschließt Buyback-Parameter** (off-chain oder via Proposal-JSON):
   - `amountStableIn` (oder Obergrenze)
   - Ziel-Asset (z. B. Governance-Token / 1kUSD)
   - Slippage-/Discount-Grenzen (bps)
   - optional: Zeitfenster / Deadline

2. **DAO triggert Vault-Call**, z. B.:
   - `executeBuyback(uint256 amountStableIn, uint256 minOut, uint256 deadline)`

3. **BuybackVault prüft:**
   - `isPaused` des zugehörigen Safety-Moduls (kein Buyback, wenn pausiert)
   - genügend Stable-Balance (`stableBalance() >= amountStableIn`)
   - Deadline nicht überschritten

4. **Execution-Routing:**
   - Stage B (Minimal): Routing über einen **dedizierten Swap-Adapter oder PSM-Fassade**  
     (Details siehe 2.3)

5. **Nach Execution:**
   - Ziel-Asset verbleibt im Vault (für spätere DAO-Entscheidung: Burn, Treasury, Liquidity)
   - Event-Emission mit allen relevanten Parametern:
     - `amountStableIn`, `amountOut`, `targetAsset`, `executor`, `timestamp`

### 2.2. Safety- und Governance-Gates

Vor jeder Ausführung:

- **Safety Hook:**  
  - `require(!safety.isPaused(MODULE_ID), "BuybackVault: paused");`
  - `MODULE_ID` wird konsistent mit den anderen Modulen vergeben (z. B. `"BUYBACK_VAULT"`).

- **DAO-Only Execution:**  
  - `onlyDao`-Modifier (wie bei `fundStable` / Withdraw-Funktionen)
  - Keine direkte User-Interaktion in Stage B (reiner Governance-Mechanismus).

- **Invarianten:**
  - Keine externen Calls, wenn pausiert
  - Keine Ausführung ohne ausreichende Stable-Liquidität
  - Keine Ausführung nach `deadline`

### 2.3. Routing-Varianten

Stage B soll den **Routing-Mechanismus kapseln**, so dass später unterschiedliche Pfade möglich sind:

1. **PSM-nativer Pfad (empfohlen als erster Implementierungsschritt):**
   - Stable → PSM → 1kUSD (oder umgekehrt, je nach Target)
   - Nutzung eines minimalen Interfaces (z. B. `swapTo1kUSD` / `swapFrom1kUSD`)
   - Vorteile:
     - Schließt direkt an die bestehende Economic Layer (Fees/Spreads/Limits) an
     - Oracle-Health-Gates wirken indirekt über PSM-Limits / Safety

2. **DEX / AMM Pfad (Stage C / später):**
   - Stable → DEX-Router → Zielasset
   - Verwendung existierender Integrations-Dokumente  
     (`integrations/dex/docs/DEX_INTEGRATION.md`, Routing-Hints, etc.)
   - Gated über Governance-Parameter (z. B. erlaubte DEX-IDs, max. Slippage)

In Stage B wird im Code ein **einfacher, aber klar strukturierter Hook** vorgesehen, z. B.:

- `function _routeBuybackStable(uint256 amountStableIn) internal returns (uint256 amountOut);`

Die konkrete Implementierung (PSM vs. DEX) kann dann iterativ erfolgen, ohne das Custody-Modell zu verändern.

---

## 3. Parametrisierung (Governance-Driven)

Stage B hängt an folgenden Parametern (teilweise bereits in anderen Modulen genutzt, teilweise neu):

- **Slippage-Grenzen (bps)**
  - z. B. `buyback:maxSlippageBps`
  - Definiert die maximale Abweichung zwischen erwartetem und tatsächlichem Out-Amount.

- **Volume-Limits pro Execution**
  - z. B. `buyback:maxStablePerTx`
  - Schützt vor "All-in"-Fehlkonfigurationen und front-running Governance-Fehlern.

- **Frequenz-Limits (optional, später)**
  - z. B. min. Zeit zwischen zwei `executeBuyback`-Aufrufen.

Diese Parameter können später über die bestehende **ParameterRegistry** und das Governance-Playbook (`docs/governance/parameter_playbook.md`) angebunden werden. Für Stage B reicht es, sie **konzeptionell** zu verankern und im Code als TODO/Hook zu markieren.

---

## 4. Stage C – Erweiterte Features (Ausblick)

Stage C ist bewusst **nicht Teil des v0.50/v0.51-Scopes**, soll aber im Plan dokumentiert sein:

- **Multi-Route Buybacks**
  - Splitting von Stable auf mehrere Routen (PSM, DEX, OTC-Adapter)
  - Gewichtung / Priorisierung per Parameter

- **Indexing & Telemetrie-Hooks**
  - Emission zusätzlicher Events für Off-Chain-Indexing (z. B. Buyback-Reports)
  - Anbindung an bestehende Health-/Telemetry-Schemata (`indexer/schemas/health.schema.json`)

- **Guardian-/Safety-Automatisierung**
  - Trigger-Regeln, wann Buybacks automatisch deaktiviert werden (z. B. Oracle ungesund, PSM-Limits nahe Cap, etc.)

Diese Punkte bleiben als **Future Work** markiert, damit sie von späteren DEV-Aufträgen gezielt abgearbeitet werden können, ohne den aktuellen stabilen Kern zu gefährden.

---

## 5. Zusammenfassung

- Stage A ist abgeschlossen: Custody, DAO-only, Pause-Hooks, Tests grün.
- Dieses Dokument definiert Stage B/C:
  - **Stage B:** Minimaler, sicherheits-gateter Execution-Flow für Stable → Zielasset (primär via PSM).
  - **Stage C:** Erweiterte Multi-Route- und Telemetrie-Funktionen.

Nächste konkrete Schritte im Code (separater DEV-Auftrag):

1. Minimal-Interface für die gewählte PSM-/Swap-Fassade definieren.
2. `executeBuyback`-Funktion im BuybackVault mit:
   - DAO-only Guard
   - Safety-Pause-Check
   - Deadline/Slippage-Checks (hart codiert oder über Registry-Hooks vorbereitet)
3. Interne Routing-Funktion `_routeBuybackStable` implementieren (zunächst nur PSM-Pfad).
4. Dedizierte Regression-Tests für Buyback-Execution hinzufügen:
   - Erfolgspfad
   - Pausenfall
   - Slippage-/Limit-Verletzung (revert)
EOL

echo "✓ BuybackVault Execution Plan written to $FILE"
