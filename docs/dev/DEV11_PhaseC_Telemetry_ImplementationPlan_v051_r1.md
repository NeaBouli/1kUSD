# DEV-11 Phase C – Telemetry Implementation Plan (v0.51.x)

**Role:** DEV-11 – OracleRequired Telemetry & Indexer  
**Phase:** C – Implementation Planning (Reference Telemetry Stack)  
**System:** 1kUSD – Economic Layer v0.51.x

---

## 1. Scope & Zielsetzung

Phase C baut auf Phase B (Telemetry Preview) auf und beschreibt **konkret**, wie
eine minimale, aber belastbare Telemetrie-/Indexer-Implementierung für
OracleRequired-Zustände aussehen soll – ohne hier schon Code zu liefern.

Ziele:

- Referenz-Architektur für:
  - PSM- und BuybackVault-Indexer (OracleRequired-Fälle),
  - minimale Storage-Schemata (Events, Reverts, Reason Codes, Flags),
  - Metriken & Dashboards,
  - Alerts für Oracle-bezogene Störungen.
- Explizite Abgrenzung:
  - Was muss on-chain unverändert bleiben (Economic Layer v0.51.x ist frozen).
  - Was kommt als Off-Chain-Stack (Indexers, Pipelines, Dashboards).
- Basis für spätere DEV-Wellen:
  - „DEV-11 Phase C – Implementation“ (Indexers & Metriken),
  - optional „DEV-11 Phase D – Dashboards & Alerting“.

Out-of-scope:

- Keine Änderungen an Solidity oder Foundry-Tests.
- Keine CI-Erweiterungen.
- Keine konkrete Wahl eines Stack-Anbieters (Prometheus, Loki, ELK, Timescale…);
  es geht um das **Modell**, nicht um Vendor-Love.

---

## 2. Vorhandene Grundlagen (Phase B & Governance Toolkit)

Bereits umgesetzt (Stand v0.51.x):

- `DEV11_PhaseB_Telemetry_TestPlan_r1.md`
  - Definiert Reason Codes und Events als Observability-Signale:
    - `PSM_ORACLE_MISSING`
    - `BUYBACK_ORACLE_REQUIRED`
    - `BUYBACK_ORACLE_UNHEALTHY`
  - Beschreibt, dass Tests nur die Signale prüfen, nicht Business-Logik duplizieren.

- Indexer-Dokumentation:
  - `docs/indexer/index.md`
    - Einstiegspunkt für Indexer-Doku.
  - `docs/indexer/indexer_buybackvault.md`
    - Guidance für BuybackVault-Events & OracleRequired-Fehler.
  - `docs/indexer/indexer_psm.md`
    - OracleRequired-Telemetrie für `PSM_ORACLE_MISSING`
    - Empfehlung, Reason Codes explizit zu speichern und Flags abzuleiten.

- OracleRequired Governance & Runtime Toolkit:
  - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `GOV_Oracle_PSM_Governance_v051_r1.md`
  - `GOV_OracleRequired_Incident_Runbook_v051_r1.md`
  - `GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md`
  - `DEV12_Oracle_Governance_Toolkit_Status_v051_r1.md`
  - `RELEASE_TAGGING_GUIDE_v0.51.x.md`
  - OracleRequired-Docs-Gate in `scripts/check_release_status.sh`

Phase C knüpft hier an und beschreibt, **wie** ein Indexer/Telemetry-Stack diese
Signale technisch konsumieren und operationalisieren soll.

---

## 3. Minimal-Architektur für OracleRequired-Telemetrie

### 3.1 Komponenten

**On-Chain (bereits vorhanden, read-only):**

- Events & Reverts der Economic Layer Contracts:
  - PSM, BuybackVault, ggf. TreasuryVault / SafetyNet / FeeRouter.
- Reason Codes in Reverts:
  - `PSM_ORACLE_MISSING`
  - `BUYBACK_ORACLE_REQUIRED`
  - `BUYBACK_ORACLE_UNHEALTHY`

**Off-Chain (neu, Phase C Implementierung):**

1. **Ingestion Layer**
   - Listener / Indexer für:
     - EVM Logs (Events),
     - Tx-Reverts und Reason Strings (via Trace / RPC, wo verfügbar).
   - Verantwortung:
     - Normalisierung von Raw-Chain-Daten in ein einheitliches Rohformat.

2. **Canonical Telemetry Store**
   - Minimaler Daten-Speicher (z. B. relational oder time-series), der pro
     relevante Operation festhält:
     - `tx_hash`, `block_number`, `timestamp`
     - `contract` (PSM, BuybackVault, …)
     - `caller` (EOA / Contract)
     - `action_type` (psm_mint, psm_redeem, buyback_execute, …)
     - `success` (bool)
     - `reason_code` (string/null)
     - `oracle_required_blocked` (bool)
     - weitere Flags aus Phase B (z. B. `oracle_unhealthy`, …)

3. **Aggregation & Metrics Layer**
   - Periodische Aggregationen (Batch oder Streaming):
     - Anzahl von OracleRequired-Fehlern pro Zeitfenster.
     - Aufteilung nach:
       - Contract / action_type,
       - Caller-Kategorie (EOA vs Contract, evtl. whitelisted routes),
       - Konfigurations-Änderungsfenstern (z. B. nach Governance-Update).

4. **Dashboards & Alerting (Phase D, aber hier schon berücksichtigen)**
   - Visualisierung für Governance/Operations:
     - Zeitreihen „OracleRequired-Fehler pro Tag/Woche“,
     - Heatmaps nach Caller / Route,
     - Korrelationen mit Config-Changes (Runbooks / Checklists).
   - Alerts:
     - z. B. „mehr als N `PSM_ORACLE_MISSING` in X Minuten“,
     - „Buybacks über Y Minuten kontinuierlich blockiert“.

---

## 4. Datenmodell – Minimal-Schema

### 4.1 Operationen-Tabelle (Canonical)

Arbeitsname: `oracle_required_operations`

Pflichtfelder:

- `id` (intern, auto)
- `tx_hash`
- `block_number`
- `timestamp`
- `contract` (enum/string: PSM, BUYBACK_VAULT, ...)
- `action_type` (z. B. `PSM_MINT`, `PSM_REDEEM`, `BUYBACK_EXECUTE`)
- `success` (bool)
- `reason_code` (nullable string, z. B. `"PSM_ORACLE_MISSING"`)
- `oracle_required_blocked` (bool)
- `oracle_unhealthy_flag` (bool)
- `meta` (optional JSON für zus. Infos)

Regeln:

- `oracle_required_blocked = true` **iff** Reason Code in:
  - `PSM_ORACLE_MISSING`
  - `BUYBACK_ORACLE_REQUIRED`
  - `BUYBACK_ORACLE_UNHEALTHY` (oder zukünftige OracleRequired-Codes).
- `oracle_unhealthy_flag = true` **iff** Reason Code:
  - `BUYBACK_ORACLE_UNHEALTHY`
  - (später evtl. weitere Health-bezogene Codes).

### 4.2 Konfigurations-Änderungen

Optionale Tabelle: `oracle_config_changes`

- `id`
- `block_number`
- `timestamp`
- `changed_by` (Governance Actor / Timelock / Multisig)
- `module` (PSM, BuybackVault, OracleHealthModule, …)
- `change_summary` (string)
- `params_before` / `params_after` (JSON, optional)

Ziel:

- spätere Korrelation:
  - „Spitzen in OracleRequired-Fehlern kurz nach Konfig-Änderung X“.

---

## 5. Implementierungsschritte (Roadmap-Style)

### Phase C.1 – Minimal-Indexer & Storage

- Ziel:
  - Einen minimalen Indexer-Pfad implementieren, der:
    - PSM- und BuybackVault-Transaktionen beobachtet,
    - Reverts / Reason Codes extrahiert,
    - in das `oracle_required_operations`-Schema schreibt.

- Kernaufgaben:
  1. Auswahl der Chain-Access-Methode:
     - native RPC / Trace-Endpunkte des Zielnetzwerks,
     - oder bestehende Indexing-Frameworks (Subgraph, Subsquid, custom).
  2. Mappen der On-Chain Calls:
     - PSM: `mint`, `redeem` (oder entsprechend benannte Funktionen).
     - BuybackVault: `executeBuyback` / `performBuyback` etc.
  3. Implementieren der Reason-Code-Extraktion:
     - Standardisierte Behandlung von Solidity-Revert-Reasons.
  4. Mapping auf `reason_code` + Flags:
     - `oracle_required_blocked`,
     - `oracle_unhealthy_flag`.

### Phase C.2 – Aggregation & erste Metriken

- Ziel:
  - Basis-Metriken bereitstellen, die:
    - den Status von OracleRequired,
    - und die Häufigkeit von Fehlern pro Zeitraum sichtbar machen.

- Beispiele:
  - `oracle_required_failures_total{contract=..., action_type=..., reason_code=...}`
  - Zeitbasierte Rollups (Tag/Woche/Monat).
  - Anteil OracleRequired-Fehler an allen Operationen.

### Phase C.3 – Vorbereitung Dashboards & Alerts (Phase D)

- In Phase C nur Plan + Anforderungen formulieren:
  - Welche Panels braucht Governance?
  - Welche Alerts sind „kritisch“ vs „informativ“?
- Beispiele:
  - „PSM über 10 Minuten durchgängig `PSM_ORACLE_MISSING` → SEV-1 Alert“.
  - „BuybackVault mit > 5 `BUYBACK_ORACLE_UNHEALTHY` in 1 Stunde → SEV-2“.

---

## 6. Governance & Ops Interaktion

Die Telemetry-Implementierung soll eng an das bestehende Toolkit anschließen:

- Incident-Runbook:
  - Indexer-Daten liefern die Faktenbasis für A/B/C-Incidents.
- Runtime-Checklist:
  - kann um Telemetry-Checks erweitert werden (Phase D):
    - „Sind die relevanten Metriken vorhanden/aktuell?“
    - „Gab es in den letzten X Stunden OracleRequired-Spikes?“

Empfehlung:

- Jede spätere DEV-Welle, die Telemetry-Code anfasst, soll:
  - dieses Dokument + `DEV11_PhaseB_Telemetry_TestPlan_r1.md` als Referenz nutzen,
  - Reason-Code-Prioritäten nicht verändern,
  - neue Reason Codes **explizit** in Schema & Docs einpflegen.

---

## 7. Offene Punkte & Risiken (für Architekt:innen)

- Wahl des konkreten Indexer-/Telemetry-Stacks:
  - Risiko von Vendor-Lock-in → bewusst offen lassen, aber Anforderungen klar halten.
- Zugriff auf Revert-Reasons / Traces:
  - Nicht jede Infrastruktur liefert vollständige Trace-Daten – ggf. eigene
    Archive/Nodes nötig.
- Datenvolumen:
  - OracleRequired-Events sind selten, aber Operationen insgesamt nicht.
  - Früh Limits/Pruning-Strategien definieren.

---

## 8. Nächste Schritte (für eine spätere DEV-Welle)

Empfohlene logische Reihenfolge:

1. **DEV-11 Phase C – Minimal-Indexer MVP**
   - Umsetzung von Phase C.1 + C.2 (Code + Storage + Grundmetriken).
2. **DEV-11 Phase D – Dashboards & Alerting**
   - Fertigstellung der Visualisierung + Alert-Logik.
3. Optional:
   - Erweiterung der Telemetrie auf weitere Module (TreasuryVault, SafetyNet,
     FeeRouter), falls OracleRequired dort zukünftig relevant wird.

Dieses Dokument dient als verbindliche Architektur-Basis, bevor
konkrete Telemetry-Code-Änderungen in weiteren DEV-Wellen geplant
und umgesetzt werden.
