#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/buybackvault_plan.md"

echo "== DEV60 DOC02: append implementation status to BuybackVault plan =="

cat <<'EOL' >> "$FILE"

---

## Implementierungsstatus (DEV-60)

**Stand DEV-60:**

- On-Chain Contract: `contracts/core/BuybackVault.sol`
- Kernfunktionen:
  - `fundStable(uint256 amount)` – nur DAO, transferiert 1kUSD-Stable in den Vault.
  - `withdrawStable(address to, uint256 amount)` – nur DAO, zahlt Stable an Zieladresse aus.
  - `withdrawAsset(address to, uint256 amount)` – nur DAO, zahlt das Buyback-Asset (z. B. KASPA-Wrapper) aus.
- **Safety-Anbindung:**
  - Alle mutierenden Funktionen sind an `SafetyAutomata.isPaused(moduleId)` gekoppelt.
  - Bei pausiertem Modul sind Fund-/Withdraw-Operationen gesperrt (Guardian / Safety greift durch).
- **Access-Control:**
  - Striktes DAO-Only-Pattern für Fund- und Withdraw-Funktionen.
  - Zero-Address-Schranken für alle Zieladressen im Withdraw-Pfad.

**Tests (Foundry):**

- Datei: `foundry/test/BuybackVault.t.sol`
- Abgedeckte Pfade:
  - Konstruktor-Guards (zero stable/asset/dao/safety → revert).
  - DAO-Only für `fundStable`, `withdrawStable`, `withdrawAsset`.
  - Pause-Pfad via `SafetyStub`: bei pausiertem Modul revertet `fundStable`.
  - View-Funktionen `stableBalance()` / `assetBalance()` spiegeln tatsächliche Vault-Holdings.
- Status: Suite läuft grün und ist in die Gesamt-Foundry-Suite integriert.

**Noch offen (Folge-DEV):**

- Konkrete Buyback-Ausführung (z. B. Router-/AMM-Integration).
- Detailliertes Event-Schema für Offchain-Indexing.
- Governance-Flows (Timelock-Proposal) zur Parametrisierung von Vault-Adresse, Asset, Limits etc.

EOL

echo "✓ DEV60 DOC02: implementation status appended to $FILE"
