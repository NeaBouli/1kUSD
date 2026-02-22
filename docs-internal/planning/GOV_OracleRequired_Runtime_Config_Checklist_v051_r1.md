# GOV – OracleRequired Runtime Config Checklist (v0.51.x)

**System:** 1kUSD – Economic Layer v0.51.x  
**Thema:** Laufzeit-Konfiguration für OracleRequired (PSM & BuybackVault)  
**Zielgruppe:** Governance, Operations, Deployment/Infra-Teams  
**Bezug:**  
- ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md  
- ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md  
- GOV_Oracle_PSM_Governance_v051_r1.md  
- GOV_OracleRequired_Incident_Runbook_v051_r1.md  

---

## 1. Zweck & Scope

Dieses Dokument definiert eine **Runtime-Konfigurations-Checkliste** für alle
v0.51.x-Deployments von 1kUSD, bei denen der OracleRequired-Grundsatz greift.

Es beantwortet nicht die Frage *„Ist der Code korrekt?“* (das leisten Tests &
Audits), sondern:

> Ist die **laufende Konfiguration** von PSM, Oracle-Aggregator, Health-Modul
> und BuybackVault so gesetzt, dass OracleRequired in der Praxis erfüllt ist?

Wichtig:

- Diese Checklist ist **kein** Bestandteil des `check_release_status.sh`
  Release-Gates.
- Sie ergänzt:
  - die **Architekten-Dokumente** (Was ist fachlich gewollt?),
  - das **Incident-Runbook** (Was tun im Fehlerfall?),
  - die **Telemetry-Pläne** (Wie beobachten wir das?).

---

## 2. Wann diese Checklist verwendet wird

Empfohlene Einsatzpunkte:

1. **Vor einem neuen v0.51.x-Deployment** (Erstkonfiguration)
2. **Nach jeder relevanten Änderung** an:
   - Oracle-Aggregator
   - Health-Modul
   - PSM- oder BuybackVault-Parametern mit Oracle-Bezug
3. **Regelmäßig im Betrieb** (z. B. 1× pro Woche oder vor größeren Governance-
   Entscheidungen)
4. **Unmittelbar vor kritischen Governance-Aktionen**, z. B.:
   - Parameteränderungen am PSM (Spreads, Limits)
   - Aktivierung/Deaktivierung von Buyback-Strategien
   - großen Treasury-/Buyback-Entscheidungen

---

## 3. PSM – OracleRequired Runtime Check

### 3.1 Grundprinzip

Für den PSM gilt laut Architekten-Bundle:

- PSM **darf nicht** ohne gültigen Oracle-Preisfeed betrieben werden.
- Kein impliziter 1e18-Fallback.
- Fehlender Preisfeed ⇒ Operationen müssen mit `PSM_ORACLE_MISSING` blockieren.

### 3.2 Checklist PSM Runtime Config

**PSM-Adressierung & Assets**

- [ ] PSM-Contract-Adresse korrekt und eindeutig dokumentiert (Chain, Network).
- [ ] Eingehender Stablecoin (z. B. USDC) stimmt mit den Governance-Dokumenten
      überein.
- [ ] 1kUSD-Token-Adresse stimmt mit der produktiven v0.51.x-Deployment-Doku
      überein.

**Oracle-Aggregator**

- [ ] Der PSM ist mit einem **konkreten** Oracle-/Aggregator-Contract
      verdrahtet (Adresse dokumentiert).
- [ ] Der Oracle-/Aggregator-Contract liefert einen Preis für das richtige
      Paar (z. B. 1kUSD/USDC oder zentrale Reserve-Referenz, wie in
      ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md definiert).
- [ ] Es existieren **keine** Konfigurationen, bei denen der PSM auf einen
      Null-Adress-Oracle oder einen Dummy-Oracle zeigt.
- [ ] Der Oracle-/Aggregator-Contract ist **nicht** dauerhaft pausiert oder
      eingefroren (sofern der Contract einen Pause-Mechanismus kennt).

**Governance-Parameter**

- [ ] Alle PSM-Parameter, die indirekt vom Preis abhängen (Spreads, Caps,
      Limits), sind mit dem aktiven Oracle-Setup kompatibel:
    - Dokumentierter Ziel-Peg stimmt mit den Spreads überein.
    - Limits sind mit realistischen Marktbedingungen vereinbar.
- [ ] Es existiert ein klarer Governance-Entscheid, der dieses Oracle-Setup
      explizit bestätigt (z. B. im entsprechenden Governance-Report oder in
      On-Chain-Governance-Metadaten dokumentiert).

**Telemetry & Monitoring**

- [ ] Telemetry-/Monitoring-Stack (sofern vorhanden) dekodiert PSM-Events und
      Revert-Reasons.
- [ ] Alerts sind konfiguriert für:
    - `PSM_ORACLE_MISSING`
    - länger andauernde Pausen oder Ausfälle des Oracle-Aggregators
- [ ] Die relevanten Dashboards/Reports sind für Governance/Ops zugänglich.

---

## 4. BuybackVault – OracleRequired Runtime Check

### 4.1 Grundprinzip

Für den BuybackVault gilt:

- Buybacks in Strict-Mode sind nur zulässig, wenn:
  - Ein gültiges Oracle-Health-Modul konfiguriert ist, und
  - dieses Modul den Zustand als „gesund“ meldet.
- Bei fehlender oder ungesunder Oracle-Konfiguration muss ein Buyback mit:
  - `BUYBACK_ORACLE_REQUIRED` oder
  - `BUYBACK_ORACLE_UNHEALTHY`
  scheitern.

### 4.2 Checklist BuybackVault Runtime Config

**Vault-Adressierung & Assets**

- [ ] BuybackVault-Contract-Adresse korrekt und dokumentiert.
- [ ] Stable-Asset/Reserve-Asset-Konfiguration stimmt mit der v0.51.x-Doku
      überein (z. B. 1kUSD vs. Reserve-Asset).
- [ ] DAO-/Treasury-Adresse korrekt gesetzt.

**Oracle-Health-Modul**

- [ ] Es ist ein konkretes Oracle-Health-Modul konfiguriert:
  - Adresse dokumentiert
  - Implementierung entspricht der in den Specs beschriebenen Variante.
- [ ] Der Modus ist so gesetzt, dass das Health-Modul im Strict-Mode zwingend
      konsultiert wird (gemäß BuybackVault-Spezifikation).
- [ ] Das Health-Modul ist **aktiv** und nicht im „immer unhealthy“-Fallback
      oder in einem Wartungsmodus, der faktisch alle Operationen blockiert.
- [ ] Es existiert mindestens ein dokumentierter Test/Lauf, der zeigt, dass
      ein bewusst herbeigeführter Oracle-Ausfall mit
      `BUYBACK_ORACLE_UNHEALTHY` oder `BUYBACK_ORACLE_REQUIRED` endet.

**Governance-Parameter & Strategien**

- [ ] Alle aktiven Buyback-Strategien sind dokumentiert:
  - Strategie-IDs
  - Ziel-Assets
  - Limits (A01–A03)
- [ ] Die DAO hat explizit bestätigt, dass alle Strategien unter der Annahme
      eines funktionierenden Oracle-Health-Moduls parametriert wurden.
- [ ] Es gibt eine dokumentierte Regel:
  - Kein Aktivieren neuer Strategien, solange das Health-Modul in einem
    „unhealthy“ oder unklaren Zustand ist.

**Telemetry & Monitoring**

- [ ] Telemetry-/Monitoring-Stack dekodiert BuybackVault-Events und Revert-
      Reasons.
- [ ] Alerts sind konfiguriert für:
  - `BUYBACK_ORACLE_REQUIRED`
  - `BUYBACK_ORACLE_UNHEALTHY`
- [ ] Es gibt mindestens ein Dashboard/Report, das die Häufigkeit und den
      Kontext dieser Reverts anzeigt (z. B. um Fehlkonfigurationen oder
      marktbedingte Anomalien sichtbar zu machen).

---

## 5. Illegale oder unerwünschte Runtime-States

Die folgenden Zustände gelten aus Architekten-/Governance-Sicht als
**unerwünscht oder „illegal“** und sollten aktiv vermieden bzw. schnell
begradigt werden:

1. **PSM ohne gültigen Oracle-Preisfeed**
   - PSM ist produktiv, aber:
     - Oracle-Adresse = 0x0, oder
     - falsches Paar konfiguriert, oder
     - Oracle dauerhaft pausiert.
   - Folge:
     - Hohe Gefahr von unbemerkten Fehl-Pegs oder komplett blockierten
       Operationen.
   - Maßnahmen:
     - Sofortige Prüfung gemäß Incident-Runbook (Typ A: PSM_ORACLE_MISSING).

2. **BuybackVault ohne aktives Health-Modul im Strict-Mode**
   - BuybackVault ist produktiv, aber:
     - Kein Health-Modul gesetzt, oder
     - Modul ist deaktiviert / nicht erreichbar.
   - Folge:
     - Entweder unverantwortliche Buybacks oder dauerhafte Blockade.
   - Maßnahmen:
     - Incident-Runbook Typ B (BUYBACK_ORACLE_REQUIRED) anwenden.

3. **Health-Modul dauerhaft „unhealthy“ ohne Governance-Entscheid**
   - Health-Modul meldet dauerhaft „unhealthy“, aber:
     - Es gibt keinen dokumentierten Governance-Beschluss, der dies erklärt
       (z. B. bewusste Notbremse).
   - Maßnahmen:
     - Governance muss den Zustand formell einordnen (Notfall vs. Fehler),
       siehe Incident-Runbook Typ C (BUYBACK_ORACLE_UNHEALTHY).

4. **Konfigurations-Drift ohne Dokumentation**
   - On-Chain-Konfiguration weicht von der zuletzt dokumentierten
     Governance-/Architekten-Konfiguration ab (Oracle-Adressen, Strategien,
     Limits).
   - Maßnahmen:
     - Entweder Konfiguration korrigieren oder Governance-/Architekten-Doku
       aktualisieren, inkl. Klarstellung in den Reports.

---

## 6. Beziehung zu anderen Dokumenten

Diese Checklist ist bewusst **leichtgewichtig** und verweist für Details auf:

- **ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md**  
  → fachlicher Rahmen und Begründung für OracleRequired.

- **ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md**  
  → Status des Gesamtsystems (Tests, Release-Gate, Telemetry-Preview).

- **GOV_Oracle_PSM_Governance_v051_r1.md**  
  → Governance-Regeln speziell für den PSM und seine Oracle-Abhängigkeit.

- **GOV_OracleRequired_Incident_Runbook_v051_r1.md**  
  → Konkretes Vorgehen im Incident-Fall (A/B/C-Typen).

- **RELEASE_TAGGING_GUIDE_v0.51.x.md**  
  → Wie Releases geschnitten werden und welche Rolle das OracleRequired-
    Docs-Gate spielt.

Diese Runtime-Checklist ergänzt die oben genannten Dokumente, indem sie die
Frage beantwortet:

> „Ist unsere aktuelle Konfiguration im laufenden Betrieb mit OracleRequired
>  vereinbar – ja oder nein?“

---

## 7. Empfehlung für Governance & Ops

- Diese Checklist soll:
  - **vor jedem größeren Release**,  
  - **vor wichtigen Governance-Entscheidungen** und  
  - **nach jeder Oracle-/Health-Modul-Änderung**  
    einmal vollständig durchgegangen und dokumentiert werden.
- Ein einfacher Ansatz:
  - Checkliste als Markdown kopieren,
  - für das konkrete Deployment ausfüllen,
  - als Anhang zu Governance-/Ops-Reports ablegen.

Damit bleibt OracleRequired nicht nur ein Code- und Doku-Prinzip,
sondern wird zu einem **gelebten Betriebsstandard** im 1kUSD-Ökosystem.
