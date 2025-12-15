
# GOV Incident Runbook – OracleRequired (v0.51.x)

**System:** 1kUSD – Economic Layer v0.51.x  
**Owner:** Governance / Operations (DEV-12 Scope)  
**Version:** r1 (Preview)  

Dieses Runbook beschreibt, wie Governance- und Operations-Teams auf
OracleRequired-bezogene Störungen reagieren sollen. Es ergänzt:

- ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md
- ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md
- GOV_Oracle_PSM_Governance_v051_r1.md
- DEV11_PhaseB_Telemetry_TestPlan_r1.md
- RELEASE_TAGGING_GUIDE_v0.51.x.md

Es adressiert explizit **Runtime-Incidents**, nicht nur Release-Prozesse.

---

## 1. Scope und Zielgruppe

**Zielgruppe**

- Governance-Gremien (DAO / Multisig-Owner)
- Operations / DevOps / Runbook-Operatoren
- Incident-Commander bei Economic-Layer-Störungen

**Scope**

- Vorfälle, bei denen der Economic Layer durch OracleRequired-Verhalten
  eingeschränkt oder vollständig blockiert wird.
- Betroffene Komponenten:
  - PegStabilityModule (PSM)
  - BuybackVault
  - Oracle-Watcher / Health-Module (indirekt)

**Nicht im Scope**

- Vollständige Post-Mortem-Methodik (wird separat definiert).
- Detail-Konfiguration von Oracle-Feeds und Health-Modulen.
- Rollback-Strategien für Releases (siehe ROLLBACK_GUIDE*).

---

## 2. Schlüssel-Signale (Trigger für dieses Runbook)

Dieses Runbook wird aktiviert, sobald mindestens eines der folgenden
Signale auftritt:

1. **On-Chain Reverts / Events**
   - PSM-Operationen (Mint/Redeem/Swap) schlagen konsistent fehl mit
     Reason-Code:
     - `PSM_ORACLE_MISSING`
   - BuybackVault-Operationen schlagen fehl mit:
     - `BUYBACK_ORACLE_REQUIRED`
     - `BUYBACK_ORACLE_UNHEALTHY`

2. **Telemetry / Monitoring (DEV-11 Phase B, Preview)**
   - Dashboards oder Indexer-Views signalisieren:
     - Anstieg an OracleRequired-bezogenen Reverts.
     - Flags wie `oracle_required_blocked = true` für Buybacks.
     - Health-Status „unhealthy“ für den relevanten Oracle-Feed.

3. **Operational Alerts**
   - Alarm aus Monitoring/Alerting (z. B. Pager-Duty, Slack-Alerts):
     - „PSM oracle missing“
     - „BuybackVault oracle unhealthy/required“
   - Manuelle Meldung durch Operatoren oder Integratoren.

Sobald eines dieser Signale bestätigt ist, ist dieses Runbook **zu
befolgen**, bis der Status wieder bei „normaler Operation“ liegt.

---

## 3. Incident-Typen

Wir unterscheiden drei Haupttypen von OracleRequired-Incidents:

1. **Type A – PSM Oracle Missing**
   - On-Chain-Signal: `PSM_ORACLE_MISSING`
   - Effekt:
     - PSM-Operationen sind blockiert (kein reguläres Mint/Redeem).
   - Risiko:
     - 1kUSD kann evtl. nicht wie geplant gemint/redeemed werden.
     - Integrationen, die auf PSM-Flows setzen, scheitern.

2. **Type B – Buyback Oracle Required**
   - On-Chain-Signal: `BUYBACK_ORACLE_REQUIRED`
   - Effekt:
     - BuybackVault-Buybacks sind blockiert, weil ein Health-Modul fehlt
       oder deaktiviert ist.
   - Risiko:
     - Keine Durchführung geplanter Buybacks.
     - Strategische Maßnahmen (z. B. Treasury-Management) verzögern sich.

3. **Type C – Buyback Oracle Unhealthy**
   - On-Chain-Signal: `BUYBACK_ORACLE_UNHEALTHY`
   - Effekt:
     - Buybacks sind blockiert, weil das Health-Modul eine ungesunde
       Oracle-Situation meldet (z. B. zu großer Preissprung, stale Data).
   - Risiko:
     - Buybacks können in einer Marktstress-Situation ausfallen.
     - Falsche Reaktion könnte zusätzliche Volatilität erzeugen.

---

## 4. Sofortmaßnahmen pro Incident-Typ

### 4.1 Type A – PSM Oracle Missing

**Ziel:** Ursache identifizieren, Oracle-Feed wiederherstellen,
PSM-Operationen kontrolliert reaktivieren.

**Schritt 1 – Bestätigung**

- Prüfen:
  - On-Chain: wiederholte `PSM_ORACLE_MISSING`-Reverts bei PSM-Calls.
  - Telemetrie:
    - Health-Status für PSM-Oracle-Feed.
    - Logs/Event-Index: Zeitpunkt des ersten Auftretens.

**Schritt 2 – Konfigurations-Check**

- Prüfen (off-chain, je nach Deployment-Setup):
  - Ist der konfigurierte Oracle-Feed noch gültig (Adresse, Netzwerk)?
  - Wurde der Oracle-Alias/Key in der Konfiguration (z. B. Registry,
    Parameter-Store) verändert?
  - Wurden kürzlich Governance-Entscheidungen zur Oracle-Konfiguration
    umgesetzt (Parameter-Änderung, Contract-Upgrade)?

**Schritt 3 – Provider-/Feed-Status**

- Provider-Status prüfen:
  - Liefert der externe Oracle-Anbieter noch Daten für das relevante
    Asset/Pair?
  - Gibt es bekannte Incidents/Statusmeldungen beim Provider?

**Schritt 4 – Governance-Entscheidung**

- Wenn das Problem **konfigurationsbedingt** (z. B. falsche Adresse):
  - Korrektur der Konfiguration (gemäß GOV-Prozess).
  - Dokumentation der Änderung.
- Wenn das Problem **providerbedingt** (z. B. Feed eingestellt):
  - Entscheidung, ob:
    - ein Ersatz-Feed aktiviert,
    - ein alternativer Provider eingebunden oder
    - PSM dauerhaft in „OracleRequired-Block“-State verbleiben soll.

**Schritt 5 – Wiederaufnahme der Operation**

- Nach Korrektur:
  - Telemetrie/Tests:
    - Verifizieren, dass keine neuen `PSM_ORACLE_MISSING`-Reverts auftreten.
  - Optional:
    - Kontrollierte kleine Test-Operation (Mint/Redeem) unter Aufsicht.
  - Erst danach:
    - Freigabe für regulären Betrieb kommunizieren.

### 4.2 Type B – Buyback Oracle Required

**Ziel:** Sicherstellen, dass ein gültiges Health-Modul für Buybacks
konfiguriert ist und korrekt arbeitet.

**Schritt 1 – Bestätigung**

- On-Chain:
  - BuybackVault-Calls schlagen mit `BUYBACK_ORACLE_REQUIRED` fehl.
- Telemetrie:
  - Indexer/Monitoring zeigen passende Reverts/Flags.

**Schritt 2 – Konfigurations-Check**

- Prüfen:
  - Ist ein Health-Modul im BuybackVault konfiguriert?
  - Wurde es kürzlich geändert oder deaktiviert (Governance-Entscheid)?
  - Gibt es Diskrepanzen zwischen Dokumentation und tatsächlicher
    Konfiguration?

**Schritt 3 – Governance-Entscheidung**

- Falls kein gültiges Health-Modul existiert:
  - Governance muss entscheiden:
    - Neues Health-Modul deployen und konfigurieren, oder
    - Buybacks bewusst weiter blockiert lassen (z. B. Stress-Szenario).
- Jeder Entscheid ist zu dokumentieren (inkl. Begründung).

**Schritt 4 – Wiederaufnahme der Operation**

- Nach Setzen eines gültigen Health-Moduls:
  - Kurzer Test:
    - Buyback simulieren oder in minimalem Umfang ausführen.
  - Telemetrie:
    - Sicherstellen, dass `BUYBACK_ORACLE_REQUIRED` nicht mehr auftritt.
  - Freigabe-Kommunikation.

### 4.3 Type C – Buyback Oracle Unhealthy

**Ziel:** Verstehen, ob der Oracle-Status zu Recht ungesund ist und wie
darauf reagiert werden soll.

**Schritt 1 – Bestätigung**

- On-Chain:
  - Reverts mit `BUYBACK_ORACLE_UNHEALTHY`.
- Telemetrie:
  - Health-Modul markiert entsprechenden Feed als „unhealthy“.

**Schritt 2 – Markt-/Datenlage prüfen**

- Check:
  - Hat sich der Marktpreis tatsächlich stark bewegt?
  - Sind die Preisdaten des Providers plausibel (kein Off-by-Orders-of-Magnitude)?
  - Ist das „stale“-Kriterium erfüllt (z. B. keine Updates seit X Zeit)?

**Schritt 3 – Parametrisierung des Health-Moduls**

- Überprüfen:
  - Sind die Grenzwerte (Diff-Bps, Max-Stale etc.) angemessen?
  - Gab es kürzlich Governance-Änderungen an diesen Parametern?

**Schritt 4 – Governance-Entscheidung**

- Mögliche Entscheidungen:
  - Parameter unverändert lassen, wenn Marktstress real ist:
    - Buybacks bleiben blockiert, um Fehlpreise zu vermeiden.
  - Parameter vorsichtig anpassen (z. B. Diff-Bps erhöhen), wenn:
    - Datenlage robust ist, aber die bisherigen Grenzen zu eng sind.
- Jede Anpassung:
  - muss im Governance-Protokoll dokumentiert werden,
  - sollte mit einem kurzen Risk-Assessment versehen werden.

**Schritt 5 – Wiederaufnahme der Operation**

- Nach Anpassungen:
  - Health-Status erneut prüfen.
  - Test-Buyback unter kontrollierten Bedingungen.
  - Monitoring für erhöhte Aufmerksamkeit aktiv halten.

---

## 5. Kommunikation und Dokumentation

Für **jeden OracleRequired-Incident** sind folgende Schritte empfohlen:

1. **Incident-Ticket anlegen**
   - Eindeutige ID (z. B. ORC-YYYYMMDD-XX).
   - Typ (A, B oder C).
   - Zeitpunkt des ersten Auftretens.

2. **Kurzprotokoll**
   - Was ist passiert?
   - Welche Reason-Codes/Ereignisse lagen vor?
   - Welche Komponenten waren betroffen?

3. **Entscheidungen dokumentieren**
   - Welche Governance-Entscheidungen wurden getroffen?
   - Welche Parameter wurden geändert (falls zutreffend)?
   - Wurde ein neuer Provider / neues Health-Modul eingeführt?

4. **Post-Mortem (optional, empfohlen bei größeren Incidents)**
   - Kurze Ursachenanalyse.
   - Lessons Learned.
   - Konkrete Verbesserungsmaßnahmen (Parameter, Monitoring, Prozesse).

---

## 6. Beziehung zu anderen Dokumenten

Dieses Runbook ist explizit verknüpft mit:

- `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`  
  → definiert die zulässigen/illegale States und Reason-Codes.

- `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`  
  → beschreibt den Gesamtstatus von Bundle, Release-Gate und Telemetrie.

- `GOV_Oracle_PSM_Governance_v051_r1.md`  
  → legt Governance-Entscheidungsräume und Oracle-Pflichten fest.

- `DEV11_PhaseB_Telemetry_TestPlan_r1.md`  
  → definiert, wie Reason-Codes und Events als Observability-Signale
    behandelt werden sollen.

- `docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md`  
  → beschreibt, wie Releases nur mit vollständigem OracleRequired-Bundle
    zulässig sind (Docs-Gate).

Dieses Runbook bildet die **Operations-Sicht** auf OracleRequired-Events
und ergänzt damit das bestehende Architekten- und Governance-Material.

---

## 7. Offene Punkte / zukünftige Arbeiten

- **Runtime-Config-Sanity-Checks**
  - Eigenes Konzept/Bundle für Deploy-/Config-Checks (z. B. „Health-Check
    vor Go-Live“) ist noch zu definieren.
- **Automatisierte Alerts / Dashboards**
  - Konkrete Metriken, Thresholds und Alert-Rules müssen in zukünftigen
    DEV-11/DEV-9-Wellen ausgearbeitet werden.
- **A03 Rolling-Window-Tests**
  - Rolling-Window-Boundary-Tests bleiben ein bewusster Hardening-Schritt
    in einer späteren Phase (Phase C).

