#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat << 'DOC' > docs/reports/ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md
# ARCHITECT BULLETIN  
## OracleRequired & DEV-49 Impact (v2)

**Autor:** Architektur-Team (A/B)  
**Bezug:** DEV-49 – „OracleRequired“ für PSM & BuybackVault  
**Stand:** v0.51.x – Economic Layer / Safety Stack

---

## 1. Kontext & Scope

Dieses Bulletin fasst die Auswirkungen von **DEV-49 (OracleRequired)** auf das 1kUSD-System zusammen und verankert die getroffenen Designentscheidungen offiziell in der Architektur.

Referenzen:

- `reports/DEV43_PSM_CONSOLIDATION.md`
- `reports/DEV44_PSM_PRICE_NORMALIZATION.md`
- `reports/DEV45_PSM_ASSET_FLOWS.md`
- `reports/DEV60-72_BuybackVault_EconomicLayer.md`
- `reports/DEV87_Governance_Handover_v051.md`
- `reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`

Mit DEV-49 wird die Rolle der Oracles von einem „wichtigen Integrationsbaustein“ zu einem **Root-Safety-Layer** angehoben:

> **Kein Oracle ⇒ kein funktionsfähiges USD-Stablecoin-System.**  
> Weder PSM noch BuybackVault dürfen ohne Oracle operieren.

Dieses Dokument beschreibt:

1. die neue **Systeminvariante ORACLE_REQUIRED**,  
2. die Auswirkungen auf **PSM, BuybackVault, Guardian, Governance, Indexer**,  
3. die Konsequenzen für **künftige DEV-Blöcke** (insbesondere DEV-11, DEV-87, DEV-9/DEV-96).

---

## 2. Systeminvariante „ORACLE_REQUIRED“

### 2.1 Definition

Wir führen explizit die Invariante **ORACLE_REQUIRED** ein:

> Für jedes Modul mit Stablecoin-Exposure gilt:  
> **Ohne gültig konfiguriertes Oracle ist der Modulzustand illegal und alle externen Operationen müssen failen.**

Formale Kurzform:

- Sei `M` die Menge aller Module mit Rolle:
  - `PSM`, `BUYBACK_VAULT`, später `STRATEGY_EXECUTOR`.
- Für jedes `m ∈ M` gilt:

  - Es existiert genau ein `oracle(o)` mit:
    - `o.address != address(0)`
    - `o.isOperational() == true`
    - (optional Phase B/C) `o.health(asset) == healthy == true`

Wird diese Precondition verletzt, muss das System **hart** reagieren:

1. Revert mit spezifischem Reason-Code (z. B. `PSM_ORACLE_MISSING`, `BUYBACK_ORACLE_REQUIRED`).
2. Guardian / Safety markieren das System als **„unterbrochen“**.
3. Operator-Tools & UIs müssen diesen Zustand als **Hard Stop**, nicht als „Warnung“ darstellen.

### 2.2 Explizites Ende des „oraclefreien“ Narrativs

Mit DEV-49 wird das frühere, temporär tolerierte Narrativ „PSM kann notfalls auch ohne Oracle laufen“ beendet.  

Ab v0.51.x ist das **kein gültiger Architekturmodus** mehr, weder technisch noch governance-seitig.

---

## 3. Auswirkungen pro Modul

### 3.1 BuybackVault (A01–A03 Stack)

**Stand DEV-49:**

- `BUYBACK_ORACLE_REQUIRED` ist live in der BuybackVault-Logik, wenn:
  - `oracleHealthGateEnforced == true` **und**
  - `oracleHealthModule == address(0)`

Damit ist „Strict Mode ohne Modul“ kein harmloser Sonderfall mehr, sondern eine **harte Safety-Verletzung**.

#### A01 – Per-Op Treasury Cap

- Bleibt konzeptionell unverändert (Cap pro Operation).
- In der Error-Priorität kommt A01 **nach** OracleRequired:

  1. `BUYBACK_ORACLE_REQUIRED`
  2. `BUYBACK_ORACLE_UNHEALTHY`
  3. `BUYBACK_TREASURY_CAP_SINGLE`
  4. `BUYBACK_TREASURY_CAP_WINDOW` (A03, sobald aktiv)

#### A02 – OracleGate Strict Mode

- Strict Mode bedeutet nun formal:

  - `oracleHealthGateEnforced == true` **und** `oracleHealthModule == address(0)`  
    → `BUYBACK_ORACLE_REQUIRED`
  - `oracleHealthGateEnforced == true` **und** `oracleHealthModule != address(0)` **aber** Modul meldet `unhealthy`  
    → `BUYBACK_ORACLE_UNHEALTHY`

- Strategy-Schichten oder UIs dürfen Strict Mode **nicht** weichzeichnen  
  (kein „Trotzdem versuchen“, kein „Degrade Mode“ ohne Oracle).

#### A03 – Rolling Window Cap

- Die künftigen A03-Tests (Rolling Window, Phase DEV-11) müssen die Reihenfolge respektieren:

  1. Oracle vorhanden? (ORACLE_REQUIRED)
  2. Oracle gesund? (OracleGate / Health)
  3. Per-Op Cap (A01)
  4. Rolling Window Cap (A03)

Optional geparkte Tests (z. B. Zeitfenster-Boundaries) sind **Nice-to-have**, aber nicht blocker für DEV-49.  
Sie gehören in einen späteren DEV-11-Block (Phase B) und bauen auf OracleRequired auf.

---

### 3.2 PSM / PSMSwapCore / Limits

**Stand DEV-49:**

- Der frühere 1e18-Fallback („implizit 1:1“) wurde entfernt.
- Ohne konfiguriertes Oracle revertieren alle PSM-Flows mit **`PSM_ORACLE_MISSING`**.
- Regression-Tests (Limits, Fees, Spreads, Flows) arbeiten nun mit einem expliziten 1:1-Oracle.

#### Konsequenzen

1. **PSM ist ab jetzt immer Oracle-gebunden**

   - Es gibt keinen gültigen Produktiv-PSM ohne Oracle.
   - Auch „Legacy-PSM“ oder Test-Konfigurationen auf Mainnet/Testnet müssen ein Oracle gesetzt haben  
     (ein 1:1-Preisfeed ist erlaubt, aber `address(0)` nicht).

2. **Limits, Fees, Spreads sind definitorisch Oracle-basiert**

   - DailyCap, SingleTxCap, Fees und Spreads wirken auf **preis-normalisierte Notionalbeträge**.
   - Die Doku muss klarstellen: PSM-Limits sind in 1kUSD-Notional gemessen, abgeleitet aus Oracle-Preisen.

3. **PSMSwapCore bleibt schlanke Execution-Engine**

   - Optimierungen (Gas, Routing, Multi-Asset in Phase C) dürfen niemals an `PSM_ORACLE_MISSING` vorbeiarbeiten.
   - Jede „Low-Level-Execution“ setzt voraus, dass die Oracle-Precondition bereits erfüllt ist.

---

### 3.3 Guardian & Safety (Pause/Unpause)

**Stand DEV-49:**

- `Guardian_PSMUnpause` setzt das PSM-Oracle nun korrekt über die DAO-Rolle (im Test via `vm.prank(dao)`).
- Semantik:

  - `pause(PSM)` = Hard Stop, unabhängig vom Oracle-State.
  - `unpause(PSM)` impliziert, dass ein Oracle konfiguriert ist – andernfalls ist die Konfiguration fehlerhaft.

#### Auswirkungen

- **Unpause ohne Oracle** ist formal ein **Konfigurationsfehler**, kein legitimer Betriebsmodus.
- In künftigen Phasen ist optional:

  - „Pre-flight Checks“ des Guardians, der einen Unpause-Versuch abweist, wenn PSM in `PSM_ORACLE_MISSING` laufen würde.

---

## 4. Governance & Konfiguration

Mit DEV-49 werden bestimmte Konfigurationen formal als **illegal** eingestuft:

1. `PSM.enabled == true` **und** `psm.oracle == address(0)`
2. `BuybackVault.oracleHealthGateEnforced == true` **und** `oracleHealthModule == address(0)`
3. Strategy-/Execution-Pipelines, die Buybacks ohne vorherigen Oracle-Check auslösen können.
4. Governance-Vorlagen, die „oraclefreie“ Setups vorschlagen.

### 4.1 LEGACY_COMPAT vs STRICT

- `LEGACY_COMPAT` ist nur erlaubt, wenn:

  - ein Oracle existiert,
  - das Gate aber deaktiviert ist.

- Ohne Oracle ist `LEGACY_COMPAT` ein **illegaler Governance-Zustand**.
- `STRICT` bedeutet:

  - Oracle vorhanden,
  - OracleGate enforced,
  - Reason Codes `BUYBACK_ORACLE_REQUIRED` / `BUYBACK_ORACLE_UNHEALTHY` sind aktiv.

### 4.2 DEV-87 Governance-Handover

DEV-87 und das Governance-Playbook müssen explizit:

- die verbotenen States dokumentieren,
- Operatoren darauf hinweisen, dass:

  - PSM + BuybackVault ohne Oracle nicht nur „riskant“, sondern **unzulässig** sind,
  - Recovery-Pfad immer zuerst das Oracle repariert (oder setzt), bevor PSM/Buyback wieder aktiviert werden.

---

## 5. Monitoring, Indexer & Reason-Code-Hierarchie

Mit DEV-49 ergibt sich eine logische **Priorisierung der Reason-Codes**:

1. **Oracle Presence / Required**
   - `PSM_ORACLE_MISSING`
   - `BUYBACK_ORACLE_REQUIRED`

2. **Oracle Health**
   - `BUYBACK_ORACLE_UNHEALTHY`
   - ggf. weitere Codes auf Oracle-Layer-Ebene (stale/diff) in getrennten Reports.

3. **Treasury Caps**
   - `BUYBACK_TREASURY_CAP_SINGLE`
   - `BUYBACK_TREASURY_CAP_WINDOW` (Rolling Window / A03)

4. **Strategy / Config Layer**
   - `NO_STRATEGY_CONFIGURED`
   - zukünftige `STRATEGY_RULE_VIOLATION_*`-Codes

### 5.1 Darstellung im Monitoring

Für Indexer & Dashboards wird empfohlen:

- **Rot:** Oracle fehlt / ORACLE_REQUIRED verletzt
- **Orange:** Oracle unhealthy (HealthGate)
- **Gelb:** Treasury-Caps / Limits erreicht
- **Blau:** Strategy- / Config-Fehler (z. B. kein Profil, keine Rules aktiv)

Damit ist für Operatoren klar, ob:

- ein fundamentaler Safety-Layer brennt (Rot),
- das System „nur“ im Schutzmodus ist (Orange/Gelb),
- oder die Konfiguration unvollständig ist (Blau).

---

## 6. Auswirkungen auf DEV-Rollen & künftige Blöcke

### 6.1 DEV-11 (BuybackVault / Strategy / Tests)

DEV-11 baut ab sofort **immer** auf der Invariante ORACLE_REQUIRED auf.

Pflichten:

1. Tests für A02 / A03 müssen die Reihenfolge:

   1. Oracle vorhanden,
   2. Oracle gesund,
   3. Caps (A01/A03)

   sichtbar und deterministisch prüfen.

2. Strategy-Preview und spätere Strategy-Phasen dürfen keine Pfade haben, die
   - Buybacks ohne Oracle zulassen,
   - Oracles „schätzen“ oder degradieren.

### 6.2 DEV-87 (Governance / Handover)

DEV-87 muss:

- OracleRequired als **Hard Safety Requirement** dokumentieren,
- LEGACY-Profile so anpassen, dass sie nie ein „oraclefreies“ Setup nahelegen,
- Beispielkonfigurationen immer mit Oracle enthalten.

### 6.3 DEV-9 / DEV-96 (Infra / CI / Safety-Gates)

Infra- und CI-Tracks sollten künftig:

- spezifische Tests als **Pflicht-Gate** vor Release-Tags definieren, die:

  - `PSM_ORACLE_MISSING` korrekt triggern,
  - `BUYBACK_ORACLE_REQUIRED` im Strict Mode respektieren,
  - Guardian-Flows (Pause/Unpause) inkl. Oracle korrekt abbilden.

---

## 7. Fazit & Architektur-Entscheidung

Mit DEV-49 wird folgendes architektonisch beschlossen und umgesetzt:

1. **Oracles sind Root-Safety-Layer des Economic Layers.**
2. **Kein Modul mit USD-Exposure darf ohne Oracle operieren.**
3. **PSM und BuybackVault behandeln „kein Oracle“ als harten Fehler, nicht als Degradationsmodus.**
4. **Guardian, Governance, Strategy, Indexer und Tests** müssen diese Bedingung langfristig respektieren.

Kurzform:

> **DEV-49 macht aus Oracles eine nicht verhandelbare Systemvoraussetzung.  
> Ein „oraclefreier“ 1kUSD-Betrieb ist ab v0.51.x kein gültiger Architekturmodus mehr.**

DOC

# Log-Eintrag
echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md (OracleRequired as root safety layer)" >> logs/project.log

echo "== DEV-49 step04: architect bulletin for OracleRequired written =="
