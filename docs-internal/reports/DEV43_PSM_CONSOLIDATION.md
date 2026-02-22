# DEV-43 — PSM Consolidation & Safety Wiring

**Datum:** 2025-11-14  
**Scope:** Konsolidierung des Peg Stability Module (PSM), saubere Fassade, Safety-Gates, Limits-Enforcement, FeeRouter-Interface, Oracle-Health-Stubs und Regression-Skelette.

---

## 1. Ziele von DEV-43

- Einen **kanonischen Entry-Point** für den PSM bereitstellen (`PegStabilityModule` als IPSM-Fassade).
- **SafetyAutomata** und **PSMLimits** verbindlich in den öffentlichen Swap-Pfad integrieren.
- Den bisherigen Low-Level-Call auf `FeeRouterV2` durch ein **typisiertes Interface** ersetzen.
- Die **Oracle-Health-Checks** im PSM vorbereiten (Mathematik folgt in DEV-44/45).
- Eine erste **PSM-Regression-Suite** unter `foundry/test/psm/` anlegen.

---

## 2. Wichtige Code-Änderungen

### 2.1 PegStabilityModule als kanonische PSM-Fassade

- `contracts/core/PegStabilityModule.sol` vollständig neu strukturiert:
  - Implementiert `IPSM` und `IPSMEvents`.
  - Hält Referenzen auf:
    - `OneKUSD`
    - `CollateralVault`
    - `ISafetyAutomata`
    - `ParameterRegistry`
    - `PSMLimits`
    - `IOracleAggregator`
  - Konsistenter Einsatz von `ADMIN_ROLE` und `DEFAULT_ADMIN_ROLE`.

### 2.2 SafetyAutomata-Gate (MODULE_PSM)

- Einführung von:
  - `bytes32 public constant MODULE_PSM = keccak256("PSM");`
  - Modifier `whenNotSafetyPaused`, der `safetyAutomata.isPaused(MODULE_PSM)` prüft.
- Anwendung des Modifiers auf die Swap-Funktionen:
  - `swapTo1kUSD(...)`
  - `swapFrom1kUSD(...)`
- Ergebnis: Guardian/Safety können den PSM deterministisch pausieren.

### 2.3 PSMLimits-Enforcement

- Integration von `PSMLimits` im PSM:
  - `PSMLimits public limits;`
- Stub-Hilfsfunktion:
  - `function _enforceLimits(address token, uint256 amount) internal`
  - Aktuell: Notional = `amount` (DEV-43 Stub, echte Mathe folgt).
- Aufruf in den Swap-Funktionen:
  - `_enforceLimits(tokenIn, amountIn);`
  - `_enforceLimits(tokenOut, amountIn);`
- Ergänzend: bestehende `PSMLimits.t.sol` Tests weiter grün.

### 2.4 Oracle-Health-Stub

- Hinzufügen von `IOracleAggregator public oracle;`
- Stub-Hilfsfunktion:
  - `function _requireOracleHealthy(address token) internal view`
  - Ruft `oracle.getPrice(token)` auf und verlangt `p.healthy == true`.
- Aufruf in:
  - `swapTo1kUSD(...)` (tokenIn)
  - `swapFrom1kUSD(...)` (tokenOut)
- Hinweis: Noch **keine Preis-Mathematik**, nur Health-Check (DEV-44/45).

### 2.5 IPSMEvents & PSM-Events

- Neues Interface `contracts/interfaces/IPSMEvents.sol`:
  - `event PSMSwapExecuted(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 timestamp);`
  - `event PSMFeesRouted(address indexed token, uint256 amount, uint256 timestamp);`
- `PegStabilityModule` implementiert `IPSMEvents` und emittiert:
  - `PSMSwapExecuted(...)` in den stubbed Swap-Funktionen.
- Events dienen als einheitliche Grundlage für:
  - Indexer
  - Offchain-Monitoring
  - zukünftige Analytics.

### 2.6 IFeeRouterV2 Interface in PSMSwapCore

- Neues Interface: `contracts/router/IFeeRouterV2.sol`.
- `PSMSwapCore` verwendet nun:
  - `IFeeRouterV2 public feeRouter;`
  - `feeRouter.route(MODULE_ID, token, amountIn);`
- Der vorherige Low-Level-Call:
  - `address(feeRouter).call(abi.encodeWithSignature("route(...)"))`
  wurde entfernt.
- Ergebnis:
  - Kein „silent fail“ mehr
  - Atomic Swap + Fee Routing
  - Audit-freundliche, getypte Schnittstelle.

---

## 3. Tests & Regression-Suite

### 3.1 Bestehende PSM- und Limits-Tests

- `foundry/test/PSMLimits.t.sol`
  - Tägliche Caps
  - Single-Transaction Caps
  - DAO-only Limit-Updates
- `foundry/test/PSMSwapCore.t.sol`
  - Happy Path Swap
  - Fee-Routing-Verhalten (über IFeeRouterV2 Stub)

Alle bestehenden Tests sind nach den Änderungen weiterhin **grün**.

### 3.2 Neue Regression-Skelette

Unter `foundry/test/psm/` angelegt:

- `PSMRegression_Base.t.sol`
  - Scaffold für zukünftige End-to-End PSM-Flows.
- `PSMRegression_Limits.t.sol`
  - Scaffold für Integrations-Tests PSM ↔ PSMLimits.

Aktuell enthalten beide Dateien nur Platzhalter-Tests und dienen als Anker für DEV-44/DEV-45.

---

## 4. Teststatus nach DEV-43

Gesamtergebnis von `forge test -vv`:

- **28 Tests** insgesamt
- **0 Fehler**, **0 Skips**
- Relevante Suites u.a.:
  - PSM / Limits:
    - `PSMSwapCore.t.sol`
    - `PSMLimits.t.sol`
    - `psm/PSMRegression_*.t.sol` (Placeholder)
  - Guardian/Oracle:
    - `Guardian_PSMPropagation.t.sol`
    - `Guardian_PSMUnpause.t.sol`
    - `Guardian_PSMEnforcement.t.sol`
    - `Guardian_OraclePropagation.t.sol`
  - Safety:
    - `TestSafetyNet.t.sol`
    - `TestGuardianMonitor.t.sol`

---

## 5. Architektur-Impact

DEV-43 hebt den PSM-Bereich auf den Stand:

- Kanonische Fassade (`PegStabilityModule`) ist klar und modular.
- SafetyAutomata, Limits und Oracle sind **echte Gatekeeper**, keine Deko.
- FeeRouter ist typisiert und atomar eingebunden.
- Die Grundlage für:
  - echte Swap-Mathematik,
  - Peg-Stabilitätslogik,
  - umfassende Regressionstests

ist gelegt, ohne die aktuelle ökonomische Logik zu verändern.

---

## 6. Nächste Schritte (geplant für DEV-44/45)

- Implementierung der realen **Preis-Mathematik** im PSM (Oracle-getriebene Conversion).
- Nutzung der Oracle-Structs (Preis, Decimals, Staleness) für korrekte Amount-Berechnung.
- Erweiterung der PSM-Regression:
  - Happy Path Swaps mit realistischen Kursen.
  - Limits-Verhalten unter hoher Last.
  - Kombination aus Pause, Oracle-Health, Limits und Fees.
- Feinjustierung der Events (inkl. amountOut, Fees, Empfänger).

DEV-43 schließt damit den **Architektur-Block** ab und markiert den Übergang von „Safety & Wiring“ zu „ökonomischer Logik & Peg-Stabilität“.
