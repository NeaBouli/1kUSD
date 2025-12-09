#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== DEV-10 PhaseA: telemetry & indexer sync for BuybackVault =="

# 1) Integrations-Guide erweitern
cat <<'DOC' >> docs/integrations/buybackvault_observer_guide.md

---

## Phase A – Safety Events & Reason Codes

Phase A führt zusätzliche **Safety-Layer** für Buybacks ein (A01–A03).  
Für Integratoren ist entscheidend, die entsprechenden Events / Reason Codes korrekt auszuwerten.

### Übersicht der relevanten Situationen

Die folgenden Situationen können dazu führen, dass ein Buyback entweder
- **erfolgreich**, aber mit Safety-Begleitinformation ausgeführt wird, oder
- **abgelehnt** wird (Revert mit spezifischem Reason Code).

> Hinweis: Die exakten Event- und Fehlernamen sind in den Solidity-Contracts und  
> im Dokument `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` detailliert aufgeführt.  
> Dieser Abschnitt bietet eine Integrations-Perspektive.

### 1. A01 – Per-Operation Treasury Cap

**Situation:** Einzelne Buyback-Operation überschreitet den konfigurierten Anteil am Treasury.

- **Layer:** A01 (Per-Op Cap)
- **Typischer Reason Code (Beispiel):** `BUYBACK_TREASURY_CAP_SINGLE`
- **Bedeutung:**  
  Die angefragte Buyback-Größe liegt über dem per Operation erlaubten Anteil am Treasury.
- **Empfohlene Reaktion (Frontend / Integrator):**
  - Dem Operator / User anzeigen, dass die Operation „zu groß“ ist.
  - Optional vorschlagen, den Buyback in mehrere kleinere Operationen aufzuteilen.
  - Keine automatischen Retries ohne Anpassung der Parameter.

### 2. A03 – Rolling Window Cap

**Situation:** Die Summe aller Buybacks im aktuellen Zeitfenster überschreitet den konfigurierten Window-Cap.

- **Layer:** A03 (Rolling Window Cap)
- **Typischer Reason Code (Beispiel):** `BUYBACK_TREASURY_CAP_WINDOW`
- **Bedeutung:**  
  Das **kumulative** Volumen im betrachteten Zeitfenster ist bereits zu hoch; weitere Buybacks wären aus Treasury-Risiko-Sicht nicht zulässig.
- **Empfohlene Reaktion:**
  - Im UI kenntlich machen, dass das Treasury-Budget für dieses Zeitfenster ausgeschöpft ist.
  - Optional den erwarteten Zeitpunkt nennen, wann sich das Fenster zurücksetzt (falls Information verfügbar).
  - Für Monitoring / Alerts:
    - Alarm, wenn das Fenster regelmäßig „voll“ läuft (Hinweis auf zu aggressive Strategien).

### 3. A02 – Oracle / Health Gate: Oracle ungesund

**Situation:** Das Health-Gate stellt fest, dass die zugrunde liegenden Oracle-Daten nicht vertrauenswürdig sind.

- **Layer:** A02 (Oracle / Health Gate)
- **Typischer Reason Code (Beispiel):** `BUYBACK_ORACLE_UNHEALTHY`
- **Bedeutung:**  
  Ein oder mehrere Health-Kriterien (z. B. „Preis zu alt“, „Diff zu groß“) sind verletzt; Buybacks werden deshalb geblockt.
- **Empfohlene Reaktion:**
  - Im UI klar darauf hinweisen, dass es sich um ein **Oracle-/Infrastrukturproblem** handelt.
  - Keine Automatik, die „einfach erneut versucht“, solange der Status ungesund ist.
  - Integrations-/Ops-Teams sollten:
    - Status der Oracle-Feeds prüfen,
    - ggf. Failover-Mechanismen aktivieren.

### 4. A02 – Oracle / Health Gate: Guardian Stop

**Situation:** Ein Guardian-Signal blockiert Buybacks global oder für eine bestimmte Konfiguration.

- **Layer:** A02 (Guardian / Notbremse)
- **Typischer Reason Code (Beispiel):** `BUYBACK_GUARDIAN_STOP`
- **Bedeutung:**  
  Governance / Guardian hat einen Stop-Hebel aktiviert; Buybacks sind bis auf weiteres ausgesetzt.
- **Empfohlene Reaktion:**
  - Im UI klar kommunizieren: „Buybacks wurden durch Guardian/DAO pausiert.“
  - Keine automatischen Retries.
  - Optional Link auf ein Governance- oder Status-Panel anbieten (Begründung / Proposal).

### 5. Kombinationen & Prioritäten

In der Praxis können mehrere Backstops gleichzeitig relevant sein.  
Implementierungen sollten folgende Prioritäten berücksichtigen:

1. **Guardian-Stop (A02 / Notbremse)** – höchste Priorität, globaler Stopp.
2. **Oracle-Unhealthy (A02)** – keine Buybacks auf Basis schlechter Preisdaten.
3. **Window-Cap (A03)** – zeitbasierte Budget-Grenze.
4. **Per-Op Cap (A01)** – Limit pro Einzeloperation.

Wenn mehrere Gründe gleichzeitig zutreffen, sollte:

- der „stärkste“ Grund (z. B. Guardian-Stop) im Frontend dominieren,
- zusätzliche Details (z. B. nahezu ausgeschöpftes Window-Cap) optional angezeigt werden.

---

### Integrations-Checkliste für Phase A

Bei der Integration von BuybackVault sollten Clients / Services:

1. **Events & Reason Codes abonnieren**, die mit A01–A03 verknüpft sind.
2. **Fehlergründe im Frontend differenziert darstellen**, statt nur generische „Transaction failed“-Meldungen zu zeigen.
3. **Alarm-/Monitoring-Regeln definieren**, z. B.:
   - Häufige `BUYBACK_ORACLE_UNHEALTHY` → Oracle-Infra prüfen.
   - Häufige `BUYBACK_GUARDIAN_STOP` → Governance-Entscheidung prüfen.
   - Häufig ausgelastete Window-Caps → Treasury-Strategie überprüfen.
4. Die detaillierte Telemetry-Spezifikation aus  
   `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` berücksichtigen.
DOC

# 2) Indexer-Guide erweitern
cat <<'DOC' >> docs/indexer/indexer_buybackvault.md

---

## Phase A – Safety Reason Codes & Indexing-Strategie

Mit Phase A führt der BuybackVault zusätzliche Reason Codes ein, die für Indexer
und Monitoring-Systeme von hoher Bedeutung sind.

### 1. Ziel

Dieser Abschnitt beschreibt, wie Indexer:

- relevante Events / Reason Codes erkennen,
- sie strukturiert abspeichern,
- und daraus sinnvolle Alerts / Dashboards bauen können.

### 2. Kern-Reason-Codes (Beispiele)

> Konkrete Namen / Enums sind in  
> `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` beschrieben.  
> Die folgende Tabelle zeigt eine integratorische Sicht.

| Layer | Beispiel-Code                    | Kategorie          | Beschreibung                                                  |
|-------|----------------------------------|--------------------|---------------------------------------------------------------|
| A01   | `BUYBACK_TREASURY_CAP_SINGLE`    | Treasury / Limits  | Per-Operation Cap überschritten                              |
| A03   | `BUYBACK_TREASURY_CAP_WINDOW`    | Treasury / Limits  | Rolling Window Cap überschritten                             |
| A02   | `BUYBACK_ORACLE_UNHEALTHY`       | Oracle / Health    | Oracle-/Health-Gate meldet ungesunde Daten                   |
| A02   | `BUYBACK_GUARDIAN_STOP`          | Governance / Guard | Guardian-/DAO-Stop blockiert Buybacks                        |

Indexern wird empfohlen, Reason Codes mindestens mit folgenden Feldern zu persistieren:

- `tx_hash`
- `block_number` / `timestamp`
- `asset` (falls vorhanden)
- `amount` (falls relevant)
- `reason_code` (String / Enum)
- `layer` (A01/A02/A03)
- optional: `mode` / Konfigurationsprofil (falls aus anderen Events ableitbar)

### 3. Abgeleitete Metriken & Alerts

Aus den oben genannten Daten lassen sich u. a. folgende Metriken ableiten:

- **Cap-Auslastung pro Zeitfenster**:

  - Anteil der Zeit, in der `BUYBACK_TREASURY_CAP_WINDOW` auftritt.
  - Cumulative Volumes vs. Window-Cap.

- **Fehler-Rate pro Layer**:

  - Anteil der Buyback-Versuche, die durch A01, A02 oder A03 geblockt werden.

- **Health-Gate-Stabilität**:

  - Anzahl / Dauer der Perioden mit `BUYBACK_ORACLE_UNHEALTHY`.
  - Korrelation mit Oracle-Infrastruktur-Incidents.

- **Guardian-Stop-Episoden**:

  - Episoden-Liste von `BUYBACK_GUARDIAN_STOP` inkl. Start/Ende.
  - Verknüpfung mit Governance-Entscheidungen (z. B. Proposals).

### 4. Empfohlene Index-Struktur

In einer typischen Indexer-DB (z. B. PostgreSQL, ClickHouse, Elastic) empfiehlt sich:

- Eine Tabelle / Collection `buyback_events` mit:

  - Primärschlüssel basierend auf `(tx_hash, log_index)`
  - Index auf `timestamp`, `asset`, `reason_code`, `layer`.

- Optional eine separate Tabelle `buyback_safety_incidents` für aggregierte Sicht:

  - `incident_id`
  - `layer`
  - `reason_code`
  - `start_timestamp`
  - `end_timestamp` (falls episodenbasiert)
  - `affected_volume`
  - `metadata` (JSON für zusätzliche Felder)

### 5. Verbindung zu anderen Dokumenten

Indexer sollten neben diesem Dokument insbesondere berücksichtigen:

- `docs/dev/DEV11_Telemetry_Events_Outline_r1.md`  
  (detaillierte Definition der Reason Codes, Event-Schemata)
- `docs/integrations/buybackvault_observer_guide.md`  
  (Integrationsperspektive / empfohlene Reaktionen)
- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`  
  (High-Level-Status von Phase A)
- `docs/governance/buybackvault_parameter_playbook_phaseA.md`  
  (Governance-Profile und Parameter-Kontext)

---

### 6. Checkliste für Indexer-Implementierungen

1. **Reason Codes parsen & normalisieren** (z. B. in ein internes Enum).
2. **Layer-Tagging** (A01/A02/A03) für jede Safety-bezogene Meldung.
3. **Dashboards**:

   - Zeitreihe der geblockten vs. erfolgreichen Buybacks.
   - Heatmaps für Reason Codes über die Zeit.
   - Fenster-Visualisierung für Treasury-Cap-Auslastung.

4. **Alerts** definieren:

   - Hohe Dichte von `BUYBACK_ORACLE_UNHEALTHY` innerhalb kurzer Zeit.
   - Wiederholte `BUYBACK_GUARDIAN_STOP` ohne klare Governance-Kommunikation.
   - Window-Cap nahezu permanent ausgelastet.

DOC

# 3) Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-10 PhaseA: sync buybackvault telemetry and indexer docs for A01-A03" >> logs/project.log

# 4) Docs-Build zur Sicherheit
mkdocs build

echo "== DEV-10 PhaseA telemetry/indexer sync done =="
