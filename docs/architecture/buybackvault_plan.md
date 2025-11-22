# BuybackVault – Debug- & Architektur-Plan (DEV-59+)

## 1. Kontext

Der **BuybackVault** ist der Baustein, der überschüssige Erträge (Fees, Spreads, Treasury-Überschüsse)
nutzen soll, um:

- Marktankäufe von 1kUSD-relevanten Assets (z. B. Collateral) zu steuern,
- ggf. Protokoll-Token (künftiger Governance-Token) zurückzukaufen,
- und den Economic-/Incentive-Layer langfristig zu stabilisieren.

Aktueller Status (Stand v0.50.0):

- Contract & Tests existieren, sind aber **rot**.
- In `KNOWN-ISSUES.md` vermerkt:
  - **MockRouter Array-Initialisierung** bricht Tests/Build auf lokaler Maschine.
  - BuybackVault-Tests wurden bewusst hintenangestellt, bis PSM/Oracle-Layer stabil ist.
- Priorität: **hoch**, aber erst nach Abschluss des Economic-/Governance-Layers (DEV-43..56, DEV-58).

Dieses Dokument definiert den **Fahrplan ab DEV-59**, um BuybackVault schrittweise zu reparieren
und architektonisch sauber in den Stack einzubetten.

---

## 2. Zielbild BuybackVault im 1kUSD-Stack

Der BuybackVault soll mittelfristig:

1. **Quelle von Mitteln**
   - Eingehende Assets:
     - Teile der PSM-Fees/Spreads (z. B. via FeeRouter → BuybackVault),
     - eventuelle Treasury-Zuflüsse,
     - manuelle DAO-Zuweisungen (Timelock-gesteuert).

2. **Verwendung von Mitteln**
   - Gesteuerte Käufe von:
     - Collateral-Assets (zur Absicherung oder Glättung),
     - später optional Governance-Token (Protocol-Buybacks),
   - Verwahrung von Restbeständen / Idle-Capital.

3. **Steuerung & Governance**
   - Alle Parameter (Quoten, Asset-Whitelists, Limits) sind:
     - DAO-/Timelock-gesteuert,
     - auditierbar dokumentiert,
     - idealerweise über `ParameterRegistry` referenzierbar.

4. **Sicherheit**
   - Kein direkter „god mode“ für EOA-Admins.
   - Nur Timelock / DAO dürfen:
     - Ziel-Router setzen/ändern,
     - Asset-Listen pflegen,
     - Buyback-Quoten/Strategie anpassen.

---

## 3. Bekannte Probleme (Legacy-Status)

Aus früheren Runs / KNOWN-ISSUES:

- **Problem A – MockRouter / Array-Initialisierung**
  - Test-Suite für BuybackVault schlägt fehl wegen einer
    Array-/Struct-Initialisierung im MockRouter (kompilerspezifisch).
  - Effekt:
    - Lokale Builds brechen,
    - CI kann nicht stabil über BuybackVault laufen.

- **Problem B – Ökonomische Pfade nicht final**
  - Unklar definierte Pfade:
    - Welche Fees/Spreads und in welcher Reihenfolge im BuybackVault landen.
    - Wie stark Buybacks die PSM-Limits / Oracle-Health berücksichtigen sollen.

- **Problem C – Test-Abdeckung unscharf**
  - Tests prüfen eher „Happy Path“ als:
    - Reverts bei falscher Konfiguration,
    - Umgang mit pausierten Modulen (Guardian/Safety),
    - Routing-Fehler (z. B. Router ohne Liquidity).

---

## 4. DEV-Roadmap für BuybackVault (High-Level)

### Phase 1 – Technische Entflechtung & Build-Fix (DEV-59..60)

Ziel: **Build & Tests dürfen durch BuybackVault nicht mehr brechen.**

Vorschläge:

- DEV-59:
  - **BuybackVault-Dokument (dieses File)** als Referenz für Architekt/Dev:
    - Problemzusammenfassung,
    - Zielbild,
    - Roadmap.
- DEV-60:
  - Test-Harness trennen:
    - Legacy-Tests in `foundry/test/_legacy_BuybackVault.t.sol` auslagern,
    - Minimal-Smoke-Test für Deployment hinzufügen, der garantiert grün läuft.
  - MockRouter vereinfachen:
    - Array-Initialisierung entfernen oder durch explizite `push`-Logik ersetzen,
    - Compiler-Warnungen/Errors eliminieren.

### Phase 2 – Saubere Schnittstellen & Ökonomie-Wiring (DEV-61..63)

Ziel: **BuybackVault ist formal korrekt in den Economic Layer eingebunden.**

- DEV-61:
  - Schnittstelle definieren:
    - `IBuybackVault` Interface,
    - minimale Funktionen:
      - `deposit()`, `executeBuyback()`, `setRouter()`, etc.
  - Abgleich mit:
    - `FeeRouter`,
    - TreasuryVault / PSM-Flows.
- DEV-62:
  - Parameter-Wiring:
    - Buyback-Quoten und Limits via:
      - ParameterRegistry (z. B. `buyback:maxShareBps`, `buyback:cooldown`),
      - oder dedizierten Config-Storage, falls sinnvoll.
- DEV-63:
  - Guardian/Safety-Integration:
    - BuybackVault respektiert pausierte Module (`safety.isPaused`),
    - optional eigene `MODULE_ID = keccak256("BUYBACK")`.

### Phase 3 – Regression-Suite & Szenarien (DEV-64..65)

Ziel: **Regressions-Tests spiegeln echte Szenarien wider.**

- DEV-64:
  - Smoke-Regression:
    - Minimaler Flow:
      - Treasury → BuybackVault,
      - BuybackVault → Router → Asset-Ankauf,
      - Ergebnis: Asset-Bestände korrekt aktualisiert.
- DEV-65:
  - Edge Cases:
    - Kein Liquidity im Router,
    - falsches Asset,
    - pausierter Guardian/Safety,
    - Parameter außerhalb Limits.

---

## 5. Konkrete nächste Schritte für den Architekt/Lead-Dev

1. **Bestandsaufnahme Code**
   - Datei(en) identifizieren:
     - `contracts/core/BuybackVault.sol`
     - zugehörige Mocks:
       - `foundry/test/.../MockRouter.sol` (oder ähnlich)
     - Tests:
       - `foundry/test/BuybackVault.t.sol` (oder Legacy-Pendant).
   - Status:
     - Build & Test einmal bewusst laufen lassen,
     - aktuelle Fehlermeldungen in `KNOWN-ISSUES.md` ergänzen/aktualisieren.

2. **Minimaler CI-Durchstich**
   - Ziel:
     - BuybackVault deaktiviert die CI nicht mehr.
   - Vorgehen:
     - Entweder:
       - Legacy-Tests unter `_legacy_*.t.sol` parken und vorerst nicht in CI-Matrix aufnehmen,
     - oder:
       - eine stark vereinfachte Version des BuybackVault deployen, die:
         - Fees/Spreads noch nicht produktiv nutzt,
         - aber Deployment + Basiskonfiguration beweist.

3. **Architektur-Entscheidungen (TODO-Liste)**
   - Sollen Buybacks:
     - 1kUSD direkt stützen (z. B. Collateral-Rebalancing),
     - oder primär Governance-Token zurückkaufen?
   - Wird der BuybackVault:
     - on-chain strategisch gesteuert (Parameter),
     - oder via Offchain-Bot (Executor), der die Parameter nur ausliest?

4. **Dokumentation**
   - Dieses Dokument als Ausgangspunkt für:
     - detailliertere Spezifikation (`buybackvault_devXX.md`),
     - Governance-Parameter im bestehenden **Parameter Playbook**.

---

## 6. Zusammenfassung

- BuybackVault ist der nächste große Baustellen-Block nach erfolgreicher
  Stabilisierung von:
  - PSM (Fees, Spreads, Limits, Decimals),
  - Oracle-Health-Layer,
  - Governance-/Parameter-Dokumentation.
- Dieses Dokument dient:
  - als **Arbeitsauftrag** an den Architekten/Lead-Dev,
  - als **Referenz** für künftige DEV-Tasks (DEV-59+),
  - als Link-Ziel für KNOWN-ISSUES & Release-Notes.

Nächster voraussichtlicher Task:
- **DEV-60 – BuybackVault Legacy-Harness entkoppeln & Build stabilisieren.**
