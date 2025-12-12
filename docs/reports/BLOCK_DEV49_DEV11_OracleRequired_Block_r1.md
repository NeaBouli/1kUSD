# BLOCK REPORT – OracleRequired as Root Safety Layer (DEV-49, DEV-11, DEV-87, DEV-94)

## 1. Scope & involved DEV IDs

Dieser Block-Rapport fasst die Arbeiten rund um **OracleRequired** zusammen, die sich
über mehrere DEV-Streams erstrecken:

- **DEV-49** – OracleRequired im Code (BuybackVault, PSM, Guardian)
- **DEV-11** – Buyback-/PSM-Safety & Strategy (Handshake, Status, Backlog, Telemetrie)
- **DEV-87** – Governance-Handover v0.51
- **DEV-94** – Release-Flow / Kommunikations-Ebene (indirekt betroffen)

Ziel: Klarstellen, dass Oracles ab v0.51 **Root-Safety-Layer** des 1kUSD-Systems sind
und kein Modul (PSM, BuybackVault, Strategy, Governance) mehr „oraclefrei“ betrieben
werden darf.

---

## 2. Zusammenfassung der abgeschlossenen Arbeiten

### 2.1 DEV-49 – Code-Ebene (OracleRequired scharfgeschaltet)

- **BuybackVault Strict Mode**
  - Wenn `oracleHealthGateEnforced == true` und kein Health-Modul gesetzt ist,
    revertiert jeder Buyback mit `BUYBACK_ORACLE_REQUIRED`.
  - Es gibt keinen „Silent Degradation Mode“ mehr, in dem ohne Oracle-Gate
    Buybacks durchlaufen.

- **PSM (PegStabilityModule)**
  - Der frühere 1e18-Fallback wurde entfernt.
  - Wenn kein Oracle gesetzt ist, revertiert jeder Swap mit `PSM_ORACLE_MISSING`.
  - Alle PSM-Regressions-Tests (Limits, Fees, Spreads, Flows) laufen grün mit
    explizit gesetztem 1:1-Oracle.

- **Guardian / Unpause**
  - `Guardian_PSMUnpause` stellt sicher, dass beim Unpause ein funktionsfähiger
    PSM mit gesetztem Oracle verwendet wird.
  - AccessControl-Probleme rund um das Setzen des Oracles im Test wurden
    behoben (korrekter DAO-Context via `vm.prank`).

### 2.2 DEV-11 – Docs, Backlog & Telemetrie

- **Handshake-Report**
  - `DEV11_OracleRequired_Handshake_r1` dokumentiert den formalen Handshake
    zwischen DEV-49 und DEV-11:
    - OracleRequired ist harte Precondition für alle Buybacks.
    - PSM ohne Oracle ist kein legaler Zustand.

- **Phase A Status**
  - `DEV11_PhaseA_BuybackSafety_Status_r1` wurde erweitert:
    - Buyback-Safety wird explizit an OracleRequired gekoppelt.
    - Szenarien ohne Oracle werden als „illegal / revert“ dokumentiert.

- **Implementation Backlog (Solidity Track)**
  - `DEV11_Implementation_Backlog_SolidityTrack_r1` enthält nun einen Block
    „OracleRequired follow-ups (post-DEV-49)“:
    - Erweiterte A02-Testmatrix (BUYBACK_ORACLE_REQUIRED als harte Precondition).
    - Vorbereitende A03-Tests (Rolling Window unter OracleRequired) –
      bewusst als „Nice-to-have“ geparkt.
    - StrategyEnforcement muss OracleRequired als Root-Check respektieren.
    - Telemetrie-/Monitoring-Backlog mit Reason-Codes
      `BUYBACK_ORACLE_REQUIRED` und `PSM_ORACLE_MISSING`.

- **Phase B Telemetry/Testplan**
  - `DEV11_PhaseB_Telemetry_TestPlan_r1` wurde um OracleRequired-Invarianten
    ergänzt:
    - Kein PSM-Flow ohne Oracle.
    - Kein Buyback im Strict Mode ohne Health-Gate.
    - Keine „stillen Degradationsmodi“ in der Auswertung.

### 2.3 DEV-87 – Governance-Handover v0.51

- `DEV87_Governance_Handover_v051` enthält nun einen expliziten Abschnitt zu
  OracleRequired:
  - PSM ohne Oracle = illegaler Governance-Zustand.
  - BuybackVault Strict Mode ohne konfiguriertes Health-Modul = illegal.
  - Legacy-/Kompatibilitätsprofile sind nur zulässig, wenn ein Oracle existiert
    und das Gate bewusst deaktiviert ist.
  - Reason Codes `BUYBACK_ORACLE_REQUIRED` und `PSM_ORACLE_MISSING` sind als
    erstklassige Signale in Runbooks und Operator-Guides dokumentiert.

---

## 3. Neue Systeminvarianten (nach diesem Block)

Nach Abschluss dieses Blocks gelten folgende **Systeminvarianten**:

1. **Kein PSM-Flow ohne Oracle**
   - Wenn kein Oracle gesetzt ist, muss der PSM mit `PSM_ORACLE_MISSING`
     revertieren.
   - Ein „PSM enabled, Oracle unset“-Zustand ist architektonisch unzulässig.

2. **Kein Buyback ohne Oracle-Gate im Strict Mode**
   - Wenn das Oracle-Gate erzwungen wird (`oracleHealthGateEnforced == true`)
     und `healthModule == address(0)`, muss jeder Buyback mit
     `BUYBACK_ORACLE_REQUIRED` scheitern.

3. **Keine „oraclefreien“ Degradationsmodi**
   - Es gibt keinen zulässigen Betriebsmodus, in dem das System so tut, als
     hätte es ein Oracle (oder einen Preis), obwohl keins vorhanden ist.
   - „Magische“ 1.0-Preise als Fallback sind entfernt und architektonisch
     ausgeschlossen.

4. **Legacy-Profile nur mit existierendem Oracle**
   - Governance darf Legacy-/Kompatibilitätsprofile nur konfigurieren, wenn ein
     Oracle vorhanden ist und das Gate bewusst deaktiviert wird.
   - „No Oracle + Legacy“ ist explizit als illegaler State dokumentiert.

---

## 4. Auswirkungen auf zukünftige DEV-Phasen

- **DEV-11 A02 / A03**
  - A02-Tests müssen OracleRequired als erste Achse (Precondition) prüfen.
  - A03-Rolling-Window-Logik wird später um Szenarien wie
    „Window voll + Oracle unhealthy / fehlend“ erweitert (Park-Notiz).

- **StrategyEnforcement (Preview & Phase B/C)**
  - Strategieschicht darf niemals Buybacks ohne erfüllte OracleRequired-Bedingung
    zulassen.
  - Kein Fallback auf statische Preise oder „Blindbetrieb“.

- **DEV-94 Release-Flows**
  - Release-Dokumentation und Status-Checks müssen OracleRequired als
    unabdingbare Voraussetzung kommunizieren („kein oraclefreies 1kUSD“).
  - Reason Codes für fehlendes Oracle sind in zukünftigen
    Release-/Status-Skripten zu berücksichtigen.

---

## 5. Offene Punkte / Park-Notizen

- **A03 Rolling-Window-Tests**
  - Erweiterte Testcases für Zeitfenster-Logik unter OracleRequired sind als
    „Nice-to-have“ explizit geparkt (DEV-11 Kontext).
  - Sie werden in einem späteren DEV-11-/Test-Block nachgezogen.

- **Indexer / Dashboards**
  - Konkrete Implementierungen für Indexer und Operator-Dashboards (auf Basis
    der Reason-Codes) sind noch nicht Teil dieses Blocks, aber in den
    Backlogs verankert.

---

## 6. Referenzen

- `docs/reports/ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md`
- `docs/reports/DEV11_OracleRequired_Handshake_r1.md`
- `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md`
- `docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md`
- `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md`
- `docs/reports/DEV87_Governance_Handover_v051.md`
