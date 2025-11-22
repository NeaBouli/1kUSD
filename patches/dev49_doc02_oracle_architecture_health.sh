#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/oracle_dev49_health.md"

echo "== DEV49 DOC02: write OracleAggregator DEV-49 health architecture note =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# OracleAggregator – DEV-49 Health Gates (Stale & Diff Thresholds)

## Kontext

Der `OracleAggregator` ist die zentrale Preisschicht des 1kUSD-Systems.  
Mit DEV-49 wurde die bisher simple Mock-Variante um **auditierbare Health-Gates** erweitert:

- Zeitbasierte Stale-Erkennung (`oracle:maxStale`)
- Änderungsbasierte Sprung-Erkennung (`oracle:maxDiffBps`)
- Vollständige Konfiguration über `ParameterRegistry`
- Harmloses „Disable“-Verhalten über `0`-Werte (Backwards-kompatibel)

Diese Logik wird durch `OracleWatcher` und Guardian/Safety-Pfade konsumiert.

---

## ParameterRegistry-Integration

Der Aggregator liest folgende Keys aus der `ParameterRegistry`:

- `oracle:maxStale` (Uint, Sekunden)
  - `0` → **Stale-Gate deaktiviert**
  - `> 0` → Preis wird als „stale“ bewertet, wenn `block.timestamp - lastUpdate > maxStale`.

- `oracle:maxDiffBps` (Uint, Basis-Punkte, 1 bp = 0,01 %)
  - `0` → **Diff-Gate deaktiviert**
  - `> 0` → neue Preise werden mit dem letzten bekannten verglichen.
    - Wenn `abs(new - old) / old * 10_000 > maxDiffBps`, wird der neue Wert als **unhealthy** markiert.

Damit gilt:

- Beide Gates lassen sich separat aktivieren/deaktivieren.
- Konfiguration erfolgt rein über die Registry (kein Contract-Upgrade nötig).

---

## Health-Entscheidungslogik

### 1. Basiszustand

Der Aggregator speichert für jedes Asset eine Struktur:

```solidity
struct Price {
    int256  price;
    uint8   decimals;
    bool    healthy;
    uint256 lastUpdate;
}
setPriceMock(asset, price, decimals, healthy):

Setzt price, decimals, healthy, lastUpdate = block.timestamp.

Unterliegt notPaused-Gate des SafetyAutomata (MODULE_ID = "ORACLE").

2. getPrice(asset)
getPrice(asset) gibt ein Price-Objekt zurück, bei dem healthy wie folgt bestimmt wird:

Baseline: Start mit gespeichertem healthy-Flag.

Stale-Gate (oracle:maxStale):

Wenn maxStale == 0 → keine Staleness-Prüfung.

Wenn maxStale > 0 und block.timestamp - lastUpdate > maxStale:

healthy wird auf false gesetzt.

Diff-Gate (oracle:maxDiffBps):

Wenn maxDiffBps == 0 → keine Diff-Prüfung.

Wenn ein vorheriger Preis existiert und die relative Änderung in Bps > maxDiffBps:

healthy wird auf false gesetzt.

Das Ergebnis:

healthy == true nur, wenn:

Safety-Modul nicht pausiert,

der Wert nicht „zu alt“ ist (sofern maxStale > 0),

und die Preisbewegung nicht „zu heftig“ war (sofern maxDiffBps > 0).

SafetyAutomata & Guardian-Integration
SafetyAutomata bleibt die oberste Instanz:

Wenn MODULE_ID = "ORACLE" pausiert ist, schlagen relevante Calls (z. B. setPriceMock) über notPaused-Modifier fehl.

Das garantiert, dass im Notfall keine neuen Preise mehr gesetzt werden.

Guardian/OracleWatcher:

OracleWatcher verwendet isHealthy()/getPrice des Aggregators und propagiert den Status via Events.

Guardian-Tests (Guardian_OraclePropagation.t.sol) verifizieren:

Pausieren im Safety-Modul → Watcher-Status „Paused“.

Resume → Health-Status wieder „Operational“, solange Preise nicht durch Stale/Diff als unhealthy eingestuft werden.

Regression-Tests (DEV-49)
OracleRegression_Health.t.sol
Vier Kernfälle werden abgedeckt:

testMaxStaleZeroDoesNotAlterHealth

oracle:maxStale = 0 (Gate deaktiviert).

Preis wird gesetzt, dann vm.warp weit in die Zukunft.

Erwartung: healthy bleibt true, obwohl der Zeitstempel alt ist.

testMaxStaleMarksOldPriceUnhealthy

oracle:maxStale = 1 hours.

Frischer Preis wird gesetzt, dann vm.warp um 2 hours.

Erwartung: healthy == false wegen Staleness.

testMaxDiffBpsAllowsSmallJump

oracle:maxDiffBps = 500 (5 %).

Baseline: price = 1_000e8.

Neuer Preis: 1_040e8 (+4 %).

Erwartung: healthy == true (unterhalb Schwelle).

testMaxDiffBpsMarksLargeJumpUnhealthy

oracle:maxDiffBps = 500 (5 %).

Baseline: 1_000e8.

Neuer Preis: 2_000e8 (+100 %).

Erwartung: healthy == false (deutlich über Schwelle).

Zusammenspiel mit bestehenden Suiten
OracleRegression_Watcher.t.sol:

Stellt sicher, dass der Watcher den Health-Status korrekt übernimmt.

Guardian_OraclePropagation.t.sol:

Verknüpft Safety-Pause mit Oracle-Watcher und stellt Event-Propagation sicher.

Gesamtbild:

Oracle-Health ist jetzt doppelt abgesichert:

Durch SafetyAutomata Pause/Resume.

Durch Stale/Diff-Logik im Aggregator heraus.

Auditor-Notizen
Health-Gates sind voll dynamisch über ParameterRegistry steuerbar.

0-Werte für maxStale/maxDiffBps deaktivieren die jeweiligen Checks:

ideal für Tests, Bootstrap-Phasen oder Migrationen.

Keine EVM-spezifischen Annahmen:

Prinzip (Zeitstempel + relative Preisänderung) ist auf Kaspa-L1 oder andere Umgebungen übertragbar.

Tests decken die wichtigsten Failure-Modes ab:

Zu alte Preise,

zu große Sprünge,

sowie saubere No-Op-Konfiguration.

EOL

echo "✓ OracleAggregator DEV-49 health architecture note written to $FILE"
