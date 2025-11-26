#!/usr/bin/env bash
set -euo pipefail

echo "== DEV65 DOC01: add BuybackVault telemetry & indexing spec =="

# Sicherstellen, dass der Ordner existiert
mkdir -p indexer/docs

TELEMETRY_FILE="indexer/docs/BUYBACKVAULT_TELEMETRY.md"
INDEX_FILE="indexer/docs/INDEXING_TELEMETRY.md"
LOG_FILE="logs/project.log"

# 1) Dedizierte Telemetrie-Dokumentation für BuybackVault
cat <<'EOL' > "$TELEMETRY_FILE"
# BuybackVault Telemetry & Indexing

Dieses Dokument beschreibt, wie der **BuybackVault** aus Sicht von
Indexern / Offchain-Services beobachtet werden soll.

> Hinweis: Die unten beschriebenen Events sind aktuell **als Zielbild
> definiert** (Stage C) und können in einer späteren Iteration in
> `contracts/core/BuybackVault.sol` verdrahtet werden. Diese Datei dient
> als Spezifikation für Architekt, Indexer-Stack und Frontend.

---

## 1. Zielbild

Der BuybackVault erfüllt drei Hauptaufgaben:

1. **Funding mit Stablecoin** durch die DAO/Treasury.
2. **Ausführung von Buybacks** über den PSM (Stable → Asset).
3. **Rückführung von Restbeständen** (Stable und Asset) an die DAO.

Für alle drei Pfade sollen konsistente Events existieren, damit:

- Offchain-Indexing (z. B. Telemetrie-Dashboard, Analytics),
- Proof-of-Execution von Governance-Entscheidungen,
- sowie spätere Reporting-/Accounting-Prozesse

verlässlich auf Onchain-Daten aufsetzen können.

---

## 2. Geplante Events

### 2.1 Stable-Funding

**Event-Name (geplant):**

```solidity
event StableFunded(address indexed from, uint256 amount);
Semantik:

Wird emittiert, wenn die DAO/Treasury den Vault mit Stablecoin füllt
(z. B. via fundStable(uint256 amount)).

from ist die Adresse, von der die Stable-Tokens in den Vault fließen
(typischerweise DAO/Treasury).

amount ist der in den Vault transferierte Stable-Betrag (in Token-
Decimals, z. B. 1e18 für 1.0).

Indexing-Empfehlung:

Pro Event einen Datensatz mit:

txHash, logIndex, blockNumber, timestamp

vaultAddress, from, amount

Aggregation pro Tag/Woche/Monat für Funding-Statistiken.

2.2 Buyback-Ausführung über PSM
Event-Name (geplant):

solidity
Code kopieren
event BuybackExecuted(
    address indexed recipient,
    uint256 stableIn,
    uint256 assetOut
);
Semantik:

Wird emittiert, wenn executeBuyback(uint256 amountStable, address recipient)
erfolgreich ausgeführt wurde.

stableIn ist der vom Vault in den PSM geschickte Stable-Betrag.

assetOut ist der vom PSM an den recipient transferierte Asset-Betrag.

Indexing-Empfehlung:

Datenschema (vereinfacht):

json
Code kopieren
{
  "txHash": "0x...",
  "logIndex": 0,
  "blockNumber": 12345678,
  "timestamp": 1700000000,
  "vault": "0xVault",
  "recipient": "0xRecipient",
  "stableIn": "1000000000000000000",
  "assetOut": "990000000000000000"
}
Wichtig für:

Effektive Ausführung von Governance-Beschlüssen (wie viel Stable
wurde verbrannt / für Buybacks verwendet?).

Messung von Slippage/Spread-Effekten in Kombination mit PSM-
Telemetrie (Spreads, Fees).

2.3 Stable-Withdraw
Event-Name (geplant):

solidity
Code kopieren
event StableWithdrawn(address indexed to, uint256 amount);
Semantik:

Wird emittiert, wenn Stable-Bestände mittels
withdrawStable(address to, uint256 amount) an die DAO/Treasury oder
einen anderen Empfänger zurückgeführt werden.

to ist der Empfänger der Stable-Tokens.

Indexing-Empfehlung:

Ermöglicht die Nachverfolgung von:

Rückzahlungen / Umwidmungen von Buyback-Budgets.

Korrekturen, falls ein Governance-Beschluss zurückgerollt wird.

2.4 Asset-Withdraw
Event-Name (geplant):

solidity
Code kopieren
event AssetWithdrawn(address indexed to, uint256 amount);
Semantik:

Wird emittiert, wenn Buyback-Assets mittels
withdrawAsset(address to, uint256 amount) aus dem Vault entnommen
werden (z. B. für Treasury-Management oder Migrationen).

amount ist der Asset-Betrag in Token-Decimials.

Indexing-Empfehlung:

Analog zu Stable-Withdraw-Events:

Tracking von Bestandsänderungen im Asset,

Reporting der kumulierten Buyback-Menge pro Zeitraum.

3. Beziehung zu bestehenden Telemetrie-Dokumenten
PSM Telemetry & Invariants:

PSM-spezifische Events und Invarianten werden im PSM/Economic-Layer
dokumentiert.

BuybackVault-Events ergänzen diese Sicht um die Governance-Ebene
(Wer hat warum PSM-Buybacks ausgelöst?).

Indexing-Stack (global):

Siehe INDEXING_TELEMETRY.md für generelle DTO-Schemas,
Health/PoR-Events und Aggregationsstrategien.

BuybackVault kann als eigener Stream (z. B. buyback_vault_events)
modelliert werden, der mit PSM- und Governance-Events korreliert.

4. Implementierungsstatus
Solidity-Events sind in dieser Phase noch nicht in
BuybackVault.sol implementiert.

Dieses Dokument dient als:

Vorgabe für eine spätere Stage C,

Referenz für Architekt / Indexing-Owner,

Grundlage für Frontend-/Analytics-Dashboards.

EOL

echo "✓ BuybackVault telemetry spec written to $TELEMETRY_FILE"

2) Verweis in die globale Indexing-Telemetrie einfügen (falls Datei existiert)
if [ -f "$INDEX_FILE" ]; then
cat <<'EOL' >> "$INDEX_FILE"

BuybackVault Telemetry
Detail-Spezifikation: indexer/docs/BUYBACKVAULT_TELEMETRY.md

Geplante Events:

StableFunded(address indexed from, uint256 amount)

BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut)

StableWithdrawn(address indexed to, uint256 amount)

AssetWithdrawn(address indexed to, uint256 amount)

Diese Events sind aktuell als Zielbild spezifiziert und können in
einer späteren Stage in contracts/core/BuybackVault.sol verdrahtet
werden, sobald die Economic-Layer-Integration stabil ist.
EOL

echo "✓ Indexing telemetry index updated at $INDEX_FILE"
else
echo "ℹ INDEXING_TELEMETRY.md not found, skipping index update"
fi

3) Projekt-Log aktualisieren
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-65] ${timestamp} BuybackVault: telemetry & indexing spec added (planned StableFunded/BuybackExecuted/StableWithdrawn/AssetWithdrawn events; not yet wired in Solidity)." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV65 DOC01: done =="
