#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== DEV-11 PhaseA: governance playbook for BuybackVault safety =="

# 1) Neues Governance-Playbook für BuybackVault Phase A
cat <<'DOC' > docs/governance/buybackvault_parameter_playbook_phaseA.md
# BuybackVault – Phase A Safety Parameter Playbook

## 1. Scope & Zielgruppe

Dieses Playbook beschreibt die **Phase-A-Sicherheitsmechanismen** des BuybackVault:

- **A01 – Per-Operation Treasury Cap**
- **A02 – Oracle / Health Gate**
- **A03 – Rolling Window Cap**

Zielgruppe:

- Governance / DAO (DEV-87)
- Treasury-Ops / Guardian-Ops
- Risk / Security (DEV-8)
- Integrations- / Indexer-Teams (DEV-10)

Die Mechanismen sind **konfigurierbar**. Über geeignete Parameter-Kombinationen kann das System:

- entweder das Verhalten von **v0.51 („LEGACY_COMPAT“)** weitgehend nachbilden,
- oder in einen deutlich **strengeren Sicherheitsmodus („PHASE_A_STRICT“)** gebracht werden.

---

## 2. Überblick: Safety Layer in Phase A

### 2.1 A01 – Per-Operation Treasury Cap

**Zweck:**  
Begrenzt, wie viel des aktuellen Treasury-Volumens in **einer einzelnen Buyback-Operation** eingesetzt werden darf.

**Konzept:**

- Konfiguriert in **Basis­punkten (bps)** relativ zum Treasury-Bestand (z. B. 500 bps = 5 %).
- Wenn `amount > cap * treasuryBalance / 10_000` ⇒  
  Buyback wird mit einem spezifischen Fehler (z. B. `BuybackPerOpTreasuryCapExceeded`) verworfen.
- Gilt für beide Pfade:

  - PSM-basierter Buyback (`executeBuybackPSM`)
  - Direkt-Asset-Buyback (`executeBuyback`)

**Governance-Intuition:**

- Zu hoch gesetzt → Einzel­operationen können zu große Teile des Treasury verbrennen.
- Zu niedrig gesetzt → viele kleine Operationen nötig; Operational Overhead, aber keine Sicherheitsgefahr.

**Typische Größenordnungen (nur qualitativ):**

- 1–5 % pro Operation für konservative Setups
- 10 %+ nur für Test/Backtest-Umgebungen

---

### 2.2 A02 – Oracle / Health Gate

**Zweck:**  
Verhindert Buybacks in einer Umgebung, in der Preis-/Oracle-Daten **offensichtlich unzuverlässig oder manipuliert** sind, oder wenn der Guardian eine globale Notbremse zieht.

**Konzept:**

- Der BuybackVault verfügt über eine **konfigurierbare Health-Gate-Schicht**, die:

  - ein Oracle-/Watcher-Modul nach seinem **Health-Status** fragt und
  - ein Guardian-Signal („Stop Buybacks“) respektiert.
- Über einen **Enforcement-Schalter** (Health-Gate „an/aus“) kann entschieden werden:

  - **aus** → Buyback verläuft wie in v0.51 (keine Health-basierten Reverts),
  - **an** → bei „unhealthy“ Oracle oder aktivem Guardian-Stop wird mit eigenen Reason-Codes verworfen, z. B.:

    - `BUYBACK_ORACLE_UNHEALTHY`
    - `BUYBACK_GUARDIAN_STOP`

**Governance-Intuition:**

- Ein aktiviertes Health-Gate reduziert das Risiko von Buybacks auf Basis falscher Preise.
- Gleichzeitig besteht das Risiko, dass bei Fehlkonfiguration der Oracle-Infra legitime Buybacks unnötig geblockt werden.

**Empfehlung:**

- Frühe Mainnet-Phase:

  - Health-Gate **konfiguriert, aber mit Vorsicht** aktiviert (z. B. zunächst auf Testnet/Shadow-Mode evaluieren).
- Später:

  - Health-Gate als **fester Bestandteil** der Produktions-Defense-in-Depth-Strategie.

---

### 2.3 A03 – Rolling Window Cap

**Zweck:**  
Begrenzt die **Summe mehrerer Buybacks über ein Zeitfenster**, um ein schleichendes „Leerlaufen“ des Treasury durch viele kleine Einzeloperationen zu verhindern.

**Konzept (High-Level):**

- Das System führt intern eine **zeitbasierte Aggregation**:

  - `windowDuration` – Länge des Zeitfensters (z. B. 24h, 7 Tage).
  - `windowCapBps` – maximal erlaubter kumulativer Anteil des Treasury im Fenster (bps).
  - `windowStart` + `windowAccumulator` – merken, wann das Fenster begonnen hat und welche Share bereits verbraucht wurde.
- Für jede Buyback-Operation wird:

  1. Bei Bedarf das Zeitfenster „gerollt“ (Startpunkt aktualisiert, Accumulator reset).
  2. Der neue Buyback-Share zum Accumulator addiert.
  3. Geprüft, ob `windowAccumulator` > `windowCapBps` → in diesem Fall **Revert mit spezifischem Reason** (z. B. „window cap exceeded“).

**Governance-Intuition:**

- A01 schützt „Einzelschüsse“, A03 schützt vor „Serienfeuer“.
- Zusammen verhindern beide, dass entweder:

  - eine einzelne Operation das Treasury stark reduziert,
  - oder viele kleine Operationen über ein Zeitfenster das Treasury übermäßig angreifen.

**Typische Größenordnungen (qualitativ):**

- `windowDuration` in der Spanne „Stunden bis Tage“ (z. B. 24–168 Stunden).
- `windowCapBps` typischerweise > A01-Cap, z. B.:

  - A01 = 5 % pro Operation,
  - A03 = 15–30 % pro Fenster.

---

## 3. Konfigurationsprofile („Modes“)

Die folgenden Profile sind **keine bindenden Vorgaben**, sondern Orientierungs­punkte für Governance-Entscheidungen.

### 3.1 LEGACY_COMPAT (Phase-A-Layer neutralisiert)

Ziel: Verhalten möglichst nah an v0.51, geeignet z. B. für:

- sehr frühe Produktionsphasen mit geringer Aktivität,
- Migrationsphasen, in denen man zuerst nur die Basisfunktionen validieren möchte.

**Charakteristik:**

- A01 – Per-Op Cap: auf einen **sehr hohen Wert** gesetzt oder faktisch deaktiviert.
- A02 – Health Gate: **Enforcement aus** (Health-Signale können optional geloggt, aber nicht enforced werden).
- A03 – Rolling Window Cap: **de facto deaktiviert**, z. B. durch sehr hohen Window-Cap.

**Risiko-Profil:**

- Bietet kaum zusätzlichen Schutz über die v0.51-Logik hinaus.
- Eignet sich nicht als Dauerlösung für ein System mit signifikantem Assets-Under-Management.

---

### 3.2 CONSERVATIVE_START (empfohlener Mainnet-Einstieg)

Ziel: Buyback-Funktionalität **aktiv**, aber mit deutlich reduzierter Angriffsfläche.

**Charakteristik (qualitativ):**

- A01 – Per-Op Cap: moderater Wert, z. B. im niedrigen einstelligen Prozentbereich.
- A02 – Health Gate:

  - aktiviert, aber zunächst mit **konservativer** Oracle-/Watcher-Konfiguration,
  - klare Operational-Prozesse für „wie heben wir einen fälschlich ausgelösten Stop wieder auf?“.
- A03 – Rolling Window Cap:

  - Fenster-Dauer passend zur Governance-Kadenz (z. B. 24h / 7d),
  - Cap so gewählt, dass in einem Fenster mehrere sinnvolle Operationen möglich sind, ohne das Treasury zu stark zu belasten.

**Risiko-Profil:**

- Deutlich höhere Safety als LEGACY_COMPAT.
- Rest-Risiko primär in der Qualität der Oracle- / Guardian-Konfiguration.

---

### 3.3 PHASE_A_STRICT (Maximal konservativ)

Ziel: Buybacks nur dann, wenn sowohl Einzel- als auch Zeitfenster-Limits eng gesetzt sind und Health-Gate strikt enforced wird.

**Charakteristik (qualitativ):**

- A01 – Per-Op Cap: relativ niedrig, z. B. im Bereich 1–2 %.
- A02 – Health Gate: strikt aktiviert; jede „Unhealthy“-Situation führt zum Blocken von Buybacks.
- A03 – Rolling Window Cap: so gewählt, dass selbst bei vielen kleinen Operationen nur ein begrenzter Anteil des Treasury im Fenster verbraucht werden kann.

**Einsatzszenarien:**

- Phasen erhöhter Marktvolatilität,
- nach einem sicherheits­relevanten Vorfall,
- während enger Audits oder bei erhöhtem regulatorischen Druck.

---

### 3.4 LAB_AGGRESSIVE (Test / Simulation)

Ziel: In Testnet- oder Simulationsumgebungen die Grenzen des Systems erkunden.

**Charakteristik:**

- A01 – Per-Op Cap: teilweise sehr hoch, um Stress-Tests zu ermöglichen.
- A02 – Health Gate: je nach Testziel an/aus.
- A03 – Rolling Window Cap: so eingestellt, dass Extremfälle (nahezu vollständige Treasury-Drain über einen Zeitraum) simuliert werden können.

**Wichtiger Hinweis:**  
Dieses Profil **ist nicht** für Produktions­umgebungen gedacht.

---

## 4. Governance-Prozess & Verantwortlichkeiten

1. **Parameter-Änderungen nur über Governance-Mechanismen**

   - Änderungen an A01/A02/A03 müssen den gleichen Prozess durchlaufen wie andere kritische Parameter (Timelock, On-Chain-Proposals, etc.).

2. **Vor jeder Änderung: Risk-Review**

   - Risk/Security (DEV-8) sollte bewerten:

     - Auswirkungen auf Treasury-Risiko,
     - Interaktion mit bestehenden Strategien,
     - mögliche Downgrade-Szenarien.

3. **Nach jeder Änderung: Monitoring**

   - Integrations-Teams / Indexer (DEV-10) sollten:

     - Buyback-Events,
     - Reason-Codes,
     - Auslastung der Caps (A01/A03)

     aktiv überwachen.

4. **Dokumentation**

   - Jede Parameter-Änderung sollte in einem öffentlichen Changelog oder Governance-Protokoll dokumentiert werden (inkl. Profil-Zuordnung, z. B. „Wechsel auf CONSERVATIVE_START“).

---

## 5. Beziehung zu anderen Dokumenten

Dieses Playbook ergänzt:

- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`  
  *(technischer Statusbericht zu A01–A03)*
- `docs/governance/parameter_playbook.md`  
  *(allgemeine Governance-Parameter-Guidelines)*
- `docs/integrations/buybackvault_observer_guide.md`  
  *(Events & Reason-Codes aus Integratoren-Sicht)*
- `docs/indexer/indexer_buybackvault.md`  
  *(Indexing-Strategie für Buyback-Events)*
DOC

# 2) Governance-Index um Playbook-Eintrag ergänzen (einfach anhängen)
cat <<'IDX' >> docs/governance/index.md

## BuybackVault Safety – Phase A

- [BuybackVault Phase A safety parameter playbook](buybackvault_parameter_playbook_phaseA.md)
IDX

# 3) Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 PhaseA: add governance playbook for BuybackVault safety parameters" >> logs/project.log

# 4) Docs-Build
mkdocs build

echo "== DEV-11 PhaseA governance playbook done =="
