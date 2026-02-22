# Governance Overview & Einstieg

Dieses Verzeichnis bündelt alle Governance-relevanten Unterlagen für das 1kUSD-Protokoll.
Es dient als Einstiegspunkt für:

- DAO / Tokenholder
- Risk Council
- Treasury / Financing
- Guardian / Safety-Rollen
- Auditoren & Reviewer

---

## 1. Economic Layer (High-Level)

Der Economic Layer von 1kUSD besteht grob aus drei Bausteinen:

1. **PSM (PegStabilityModule)**
   - Swap zwischen Collateral-Token und 1kUSD
   - Fees & Spreads (Mint/Redeem) via ParameterRegistry
   - Limits (dailyCap, singleTxCap) über den PSMLimits-Contract

2. **Oracle-Layer**
   - OracleAggregator mit Health-Gates:
     - \`oracle:maxDiffBps\`: maximal erlaubter Preis-Sprung
     - \`oracle:maxStale\`: maximal erlaubte Staleness (Sekunden)
   - OracleWatcher, der Health-Zustand überwacht und an Guardian/Safety propagiert

3. **Guardian / SafetyAutomata**
   - Kann Module pausieren (z. B. ORACLE, PSM), wenn Health-Invarianten verletzt sind
   - Dient als technische Durchsetzungsschicht von Governance-Entscheidungen

Details zu den Parametern siehe unten.

---

## 2. Governance Parameter Playbook (DE)

Das vollständige, deutschsprachige Playbook zu Governance-Parametern findest du hier:

- **Governance Parameter Playbook (DE)**
  - Pfad: \`docs/governance/parameter_playbook.md\`
  - Inhalt:
    - Rollen (DAO, Risk Council, Treasury, Guardian)
    - Typische Änderungs-Workflows (Fees, Spreads, Limits, Oracle-Health)
    - Eskalationspfade bei Incidents
    - Checklisten vor/nach Parameteränderungen

Dieses Dokument ist die primäre Referenz für alle Governance-Aktionen.

---

## 3. PSM Parameter & Registry Map

Für eine technische Sicht auf alle numerischen Parameter rund um den PSM:

- **PSM Parameter & Registry Map**
  - Pfad: \`docs/architecture/psm_parameters.md\`
  - Mapped u. a.:
    - \`psm:tokenDecimals\`, \`psm:mintFeeBps\`, \`psm:redeemFeeBps\`
    - per-Token Overrides (Decimals, Fees, Spreads)
    - Limits (über PSMLimits, nicht über Registry)
  - Erklärt, wo der jeweilige Parameter liegt (Contract vs. Registry), wer ihn ändern darf
    und wie er im Code ausgewertet wird.

---

## 4. PSM Architecture & Economic Details

Für Auditoren und Protokoll-Architekten:

- **PSM Architecture DEV-43–48**
  - Pfad: \`docs/architecture/psm_dev43-45.md\`
  - Behandelt:
    - Notional-Layer (Preis-Normalisierung auf 1k-Units)
    - reale Mint/Redeem-Flows inkl. Vault-Anbindung
    - Decimals via ParameterRegistry
    - Fees & Spreads (global + per Token) via ParameterRegistry

---

## 5. Oracle Health Gates

Die Details zu den Health-Gates des Oracles sind aktuell im README verankert:

- **Oracle Health (stale/diff checks)**
  - OracleAggregator liest \`oracle:maxDiffBps\` und \`oracle:maxStale\` aus der Registry.
  - Health wird aus Preis-Sprüngen und Staleness abgeleitet.
  - Regression-Tests:
    - \`OracleRegression_Health.t.sol\` (stale/diff Szenarien)
    - \`OracleRegression_Watcher.t.sol\` (Watcher-Propagation)

Siehe den Abschnitt *Economic Layer / Oracle health gates* in der \`README.md\` für eine
kurze, auditierbare Zusammenfassung.

---

## 6. Praktische How-To-Beispiele für die DAO

Typische Governance-Aktionen (vereinfachte Checkliste):

1. **Mint-Fee für einen neuen Collateral erhöhen**
   - Analyse durch Risk Council (Ökonomie, Marktliquidität, Volatilität)
   - Vorschlag inkl. Zielwert (z. B. 30 → 50 bps) dokumentieren
   - DAO-Proposal erstellen:
     - Änderung von \`psm:mintFeeBps\` oder per-Token-Override
   - Vote & Timelock abwarten
   - Nach Ausführung:
     - Tests/Simulationen (Dry-Run über Script oder Testnet)
     - Monitoring (Swap-Volumen, Slippage, Oracle-Health)

2. **Tägliches Limit (dailyCap) anpassen**
   - Nur über den \`PSMLimits\`-Contract (nicht Registry).
   - Vorschlag durch Risk Council → DAO-Vote → Ausführung.
   - Nachlaufende Überwachung: ob Caps zu restriktiv oder zu locker sind.

3. **Oracle-Health schärfer einstellen**
   - Anpassung von \`oracle:maxDiffBps\` und/oder \`oracle:maxStale\`.
   - Trade-off: Sensibilität vs. False Positives (unnötige Pausen).
   - Jede Änderung sollte von Guardian/Safety mit vorbereitet werden.

Dieses Index-Dokument soll als Startpunkt dienen – Details, Formeln und
Corner-Cases stehen jeweils in den verlinkten Spezial-Dokumenten.

## BuybackVault Safety – Phase A

- [BuybackVault Phase A safety parameter playbook](buybackvault_parameter_playbook_phaseA.md)

## DEV-12

- [DEV-12 – Governance documentation plan](DEV12_Governance_Docs_Plan_r1.md)
- [GOV: Oracle & PSM governance (v0.51)](GOV_Oracle_PSM_Governance_v051_r1.md)

## OracleRequired – Incident Handling (v0.51.x)

- **GOV_OracleRequired_Incident_Runbook_v051_r1.md** – operational runbook for
  handling OracleRequired-related incidents (`PSM_ORACLE_MISSING`,
  `BUYBACK_ORACLE_REQUIRED`, `BUYBACK_ORACLE_UNHEALTHY`), aligned with:
  - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `GOV_Oracle_PSM_Governance_v051_r1.md`
\n

## OracleRequired – Runtime configuration checklist (v0.51.x)

- **GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md** – runtime
  configuration checklist for OracleRequired in v0.51.x. To be used:
  - vor Deployments / größeren Upgrades,
  - vor/nach wichtigen Governance-Entscheidungen,
  - nach Änderungen an Oracle-/Health-Config.
  Stellt sicher, dass:
  - der PSM nie ohne gültigen Oracle-Pricefeed betrieben wird
    (`PSM_ORACLE_MISSING` bleibt ein expliziter Fail-Mode, kein Normalzustand),
  - BuybackVault-Strict-Mode-Buybacks nur mit konfiguriertem und gesundem
    Health-Modul laufen (`BUYBACK_ORACLE_REQUIRED` /
    `BUYBACK_ORACLE_UNHEALTHY` als Schutz, nicht als Dauerzustand).
\n