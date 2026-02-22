# Governance Parameter How-To (DE)

Dieses Dokument richtet sich an **DAO**, **Timelock-Executor** und **Risk Council**.
Es beschreibt **konkret**, wie die numerischen Parameter des 1kUSD Economic Layers
(PSM, Oracle, Limits) sicher verändert werden können.

Es ergänzt:

- das **Governance Parameter Playbook (DE)**: \`docs/governance/parameter_playbook.md\`
- die **PSM Parameter & Registry Map**: \`docs/architecture/psm_parameters.md\`
- die **PSM- und Oracle-Architekturdoku**: \`docs/architecture/psm_dev43-45.md\` + README

---

## 1. Rollen & Verantwortung (Kurzüberblick)

- **DAO / Timelock**
  - Stellt die _finale_ Autorität für Parameter-Änderungen dar.
  - Führt on-chain Proposals / Queue / Execute aus.
  - Trägt die Haftung für „extreme“ Parameter (z. B. 100 % Fees, harte Caps).

- **Risk Council**
  - Bereitet Parameter-Änderungen vor (Daten, Szenarien, Ranges).
  - Formuliert **Change Requests** inkl. Begründung und erwarteter Effekte.
  - Empfiehlt konkrete Werte (z. B. 50 bps → 75 bps für \`psm:mintFeeBps\`).

- **Guardian / Safety Automata**
  - Nutzt Oracle-Health-Signale (\`oracle:maxDiffBps\`, \`oracle:maxStale\`).
  - Kann PSM/Oracle bei Bedarf pausieren (Guardian-Module).
  - Dient als zusätzliche „Notbremse“ neben Parametern.

---

## 2. Parameter-Gruppen

Zur Erinnerung (Details siehe \`psm_parameters.md\`):

### 2.1 PSM – Fees & Spreads

- **Global Fees (Basis):**
  - \`psm:mintFeeBps\` – Mint-Fee in Basispunkten (Bps, 1 % = 100).
  - \`psm:redeemFeeBps\` – Redeem-Fee in Bps.

- **Per-Token Overrides (Collateral-spezifisch):**
  - \`KEY_MINT_FEE_BPS\` + Token-Adresse → \`mintFeeBps\` Override.
  - \`KEY_REDEEM_FEE_BPS\` + Token-Adresse → \`redeemFeeBps\` Override.

- **Spreads (Preisaufschläge/Abschläge):**
  - Global:
    - \`psm:mintSpreadBps\`
    - \`psm:redeemSpreadBps\`
  - Per-Token:
    - \`KEY_MINT_SPREAD_BPS\` + Token-Adresse
    - \`KEY_REDEEM_SPREAD_BPS\` + Token-Adresse

- **Empfohlene Ranges (Orientierung, kein Zwang):**
  - Alltagsbetrieb:
    - Fees: 0 – 100 bps (0 – 1 %)
    - Spreads: 0 – 200 bps (0 – 2 %)
  - Defensive / Stress-Modus:
    - Fees: bis 300 bps (3 %)
    - Spreads: bis 500 bps (5 %)
  - Alles darüber sollte als **Sonderfall / Notfallmaßnahme** behandelt werden.

### 2.2 PSM – Limits (PSMLimits)

- **Daily Cap**: max. 1kUSD-Notional pro Tag.
- **Single Tx Cap**: max. 1kUSD-Notional pro Transaktion.

**Wichtig:**  
Diese Caps liegen im **PSMLimits-Contract**, _nicht_ in der Registry.  
Sie werden über Admin-Funktionen von \`PSMLimits\` gesetzt (siehe Architekturdoku).

### 2.3 Oracle – Health-Gates

Gesteuert über \`ParameterRegistry\`:

- \`oracle:maxDiffBps\`
  - Max. erlaubter relativer Preis-Sprung (z. B. 1 000 bps = 10 %).
  - Darüber → Oracle wird **unhealthy** markiert.

- \`oracle:maxStale\`
  - Max. Alter eines Preises in Sekunden.
  - Darüber → Oracle wird **unhealthy** (stale).

Der **OracleWatcher** propagiert diesen Health-Status an Guardian / Safety.

---

## 3. Standard-Workflow für eine Parameter-Änderung

Dieser Abschnitt beschreibt, wie Governance typischerweise vorgeht,
z. B. beim Anheben einer Fee oder beim Verschärfen von Oracle-Grenzen.

### Schritt 1 – Ausgangszustand erfassen

1. Aktuelle Parameter lesen (z. B. via:
   - Offchain-Script / Dashboard,
   - direkte \`getUint\`-Aufrufe auf \`ParameterRegistry\`,
   - oder via Read-Only-UI).
2. Dokumentieren:
   - aktueller Wert,
   - seit wann aktiv,
   - in welchem Marktumfeld eingeführt.

**Ziel:** Ein klares „Vorher“-Bild, um spätere Effekte bewerten zu können.

### Schritt 2 – Risikoanalyse & Zielbereich

- Welche Risiken genau sollen adressiert werden?
  - Zu viel 1kUSD-Minting in kurzer Zeit?
  - Unzureichende Kompensation für Volatilität eines Collaterals?
  - Verdacht auf manipulierte Oracle-Feeds?
- Definiere einen **Zielbereich**, z. B.:
  - \`psm:mintFeeBps\`: von 50 bps → Zielbereich 75–100 bps.
  - \`oracle:maxDiffBps\`: von 2 000 bps → Zielbereich 500–1 000 bps.

**Faustregel:**  
Parameter niemals **sprunghaft** um Größenordnungen ändern, außer im klar
deklarieren Notfallmodus.

### Schritt 3 – Proposal-Entwurf (offchain)

Der Risk Council bereitet einen Vorschlag auf, z. B.:

- **Titel:** „Anhebung Mint-Fee für COLL-A von 0,5 % auf 0,75 %“
- **Betroffene Parameter:**
  - \`psm:mintFeeBps\` (global) oder
  - \`KEY_MINT_FEE_BPS\` + COLL-A
- **Begründung:**
  - Beobachtete Volatilität / Drawdowns,
  - gewünschte Einnahme-Anpassung,
  - Schutz vor übermäßigem Leveraged Minting.
- **Technische Details:**
  - konkrete neue Werte (z. B. 75 bps),
  - Bezug auf die Registry-Keys.

Dieser Entwurf sollte idealerweise im Governance-Forum diskutiert werden.

### Schritt 4 – On-Chain Proposal / Timelock

1. DAO erstellt einen Proposal, der:
   - den passenden \`setUint\`-Call auf \`ParameterRegistry\` enthält, oder
   - die Admin-Funktion von \`PSMLimits\` aufruft.
2. Proposal wird **on-chain** eingereicht,
   - durchläuft Voting,
   - und wird bei Annahme in den **Timelock** eingereiht.
3. Timelock-Delay abwarten (Cooling-Off-Phase).

**Empfehlung:**  
Im Timelock-Fenster aktiv kommunizieren:
- _Was ändert sich?_
- _Ab welchem Block/Timestamp?_
- _Was bedeutet das für große Nutzer / Integrationen?_

### Schritt 5 – Execution & Verifikation

Nach Ausführung des Timelock:

1. **On-chain Verifikation:**
   - Parameter erneut aus Registry / PSMLimits lesen.
   - Prüfen, ob Wert exakt wie geplant gesetzt wurde.
2. **Smoke-Test:**
   - Ggf. mit einem kleinen Swap (Test-Setup oder produktionsnahes Dry-Run)
     die neue Fee/Spread-Struktur verifizieren:
     - passt der Output zum erwarteten Bps-Wert?
3. **Monitoring:**
   - In den ersten Blöcken nach Änderung:
     - Volumen & Verhalten der Nutzer beobachten,
     - Oracle-Health (falls Oracle-Parameter betroffen waren),
     - Guardian-/Safety-Status.

---

## 4. Spezielle Szenarien

### 4.1 Per-Token Overrides einführen

**Beispiel:** Ein bestimmtes Collateral \`COLL-X\` ist volatiler als andere.

Vorgehen:

1. Globale Fees/Spreads unverändert lassen.
2. Per-Token Keys setzen:
   - \`KEY_MINT_FEE_BPS\` + \`COLL-X\`
   - \`KEY_REDEEM_FEE_BPS\` + \`COLL-X\`
   - ggf. zusätzlich \`KEY_MINT_SPREAD_BPS\` / \`KEY_REDEEM_SPREAD_BPS\`.
3. Erwartung:
   - Andere Collaterals bleiben im globalen Schema.
   - Nur \`COLL-X\` wird „teurer“ im Mint/Redeem.

### 4.2 Limits verschärfen

Bei größeren Marktstress-Ereignissen kann es sinnvoll sein:

- **SingleTxCap** zu senken, um einzelne große Swaps zu drosseln.
- **DailyCap** zu reduzieren, um das System kontrolliert atmen zu lassen.

Vorgehen:

1. Risk Council schlägt neue Caps vor (z. B. 10 Mio → 5 Mio 1kUSD pro Tag).
2. DAO setzt Limits via Admin-Funktionen im \`PSMLimits\`-Contract.
3. Kommunikation an Market-Maker/Integrationen:
   - neue Caps,
   - mögliche Auswirkungen auf Liquidität.

### 4.3 Oracle-Health verschärfen

Wenn die Oracle-Umgebung unsicher wird (z. B. wenige Feeds, Volumen dünn):

- \`oracle:maxDiffBps\` senken:
  - kleinere Sprünge erlauben,
  - große Sprünge schneller als „unhealthy“ markieren.
- \`oracle:maxStale\` reduzieren:
  - Preise schneller als veraltet markieren,
  - stärker auf frische Updates bestehen.

**Wichtig:**  
Zu aggressive Grenzen können die Oracle-Schicht „dauerhaft rot“ machen.
Daher immer Tests im Staging/Simulationsumfeld durchführen.

---

## 5. Notfall-Playbook (High-Level)

In extremen Szenarien (z. B. schwere Marktmanipulation, Smart-Contract-Bug
im Collateral-Ökosystem) sind zwei Schienen wichtig:

1. **Guardian / SafetyAutomata**
   - PSM/Oracle-Module können pausiert werden.
   - Dient als **schnellste** Reaktionsebene.

2. **Parameter-Härtung**
   - Fees und Spreads massiv erhöhen (bis nahe 100 %),
   - Limits drastisch reduzieren,
   - Oracle-Grenzen sehr strikt setzen.

Dieses Dokument beschreibt primär die **geordneten, planbaren** Änderungen.
Für Notfall-Playbooks sollte es zusätzlich ein separates,
kurzes Runbook geben (z. B. \`emergency_playbook.md\`), auf das hier verwiesen
werden kann.

---

## 6. Zusammenfassung

- Alle ökonomisch relevanten Parameter (Fees, Spreads, Limits, Oracle-Health)
  sind **explizit dokumentiert** und über Registry + PSMLimits steuerbar.
- Governance sollte:
  - Änderungen stets **mit Kontext und Ranges** vorbereiten,
  - on-chain Proposals transparent kommunizieren,
  - nach Execution **verifizieren und monitoren**.
- Dieses How-To dient als praktische Anleitung für
  **DAO, Timelock-Executor und Risk Council**, um den Economic Layer
  sicher zu betreiben.
