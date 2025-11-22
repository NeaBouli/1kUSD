#!/usr/bin/env bash
set -euo pipefail

FILE="docs/governance/index.md"

echo "== DEV57 DOC02: write Governance docs index (DE) =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# Governance & Parameter – Übersicht

Dieses Verzeichnis bündelt alle Governance-bezogenen Dokumente für 1kUSD.
Zielgruppe sind **DAO**, **Risk Council**, **Treasury** und **Core Devs**, die
Parameter ändern oder bewerten müssen.

---

## 1. Einstieg

Wenn du neu im 1kUSD-Governance-Stack bist:

1. **Kurzüberblick lesen**
   - Rolle der Governance im 1kUSD-Protokoll:
     - Parameter steuern Risiken, Fees und Limits.
     - Alle Änderungen laufen idealerweise über Timelock / DAO.
2. **Playbook lesen** (Was gibt es überhaupt für Stellschrauben?)
3. **How-To lesen** (Wie ändere ich konkret etwas on-chain?)

---

## 2. Dokumente

### 2.1 Governance Parameter Playbook (DE)

- Datei: \`docs/governance/parameter_playbook.md\`
- Inhalt:
  - Katalog aller relevanten Parameter:
    - PSM: Fees, Spreads, Limits
    - Oracle: Health-Thresholds (Stale / Diff)
    - Weitere ökonomische Stellschrauben
  - Wo der jeweilige Parameter gespeichert ist:
    - On-chain Contract (z. B. PSMLimits)
    - \`ParameterRegistry\`-Keys
  - Welche Rolle typischerweise zuständig ist (DAO, Risk Council, Treasury)

**Zweck:**  
Strategische Sicht – *welche* Stellschrauben existieren und wie sie
zusammenspielen.

---

### 2.2 Governance Parameter How-To (DE)

- Datei: \`docs/governance/parameter_howto.md\`
- Inhalt:
  - Schritt-für-Schritt-Anleitungen:
    - Wie eine Fee-Änderung vorbereitet, kommuniziert und ausgeführt wird.
    - Wie Limits angepasst werden.
    - Welche Checks (Tests / Simulations / Off-Chain-Analysen) vorher laufen sollten.
  - Vorschlag für Governance-Prozesse:
    - RFC → Diskussion → Onchain-Proposal → Timelock → Execution.

**Zweck:**  
Operative Sicht – *wie* eine konkrete Änderung sauber umgesetzt wird.

---

## 3. Verbindung zur Architektur

Weitere relevante Architektur-Dokumente:

- **PSM Parameter & Registry Map:**  
  \`docs/architecture/psm_parameters.md\`  
  → Mapping, welche PSM-Parameter wo liegen (Contract vs. Registry).

- **PSM Economic Layer (DEV43–52):**  
  \`docs/architecture/psm_dev43-45.md\`  
  → Decimals, Fees, Spreads, Limits und ihre Regression-Suites.

- **Oracle Health Gates:**  
  Oracle-Abschnitt in der \`README.md\`  
  → Wie Stale/Diff-Checks konfiguriert werden und das Safety/Guardian-Set
  beeinflussen.

---

## 4. Verwendung in der Praxis

Empfohlener Workflow für Governance-Änderungen:

1. **Playbook konsultieren:**  
   Welcher Parameter ist überhaupt relevant?

2. **Risikoabschätzung:**  
   Internes Risk Council / Research prüft Szenarien und schlägt neue Werte vor.

3. **How-To folgen:**  
   Konkrete Schritte (Proposal, Timelock, Ausführung) anhand des How-To-Dokuments.

4. **Dokumentation aktualisieren:**  
   Neue Parameterwerte oder Policies in den Governance-Dokumenten vermerken
   (Changelog / Kommentarbereich).

So bleibt der Parameterraum nachvollziehbar, auditierbar und langfristig
wartbar.
EOL

echo "✓ Governance docs index written to $FILE"
