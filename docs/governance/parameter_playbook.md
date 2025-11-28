# Governance Parameter Playbook (1kUSD / PSM / Oracle)

> **Ziel:** Dieses Dokument ist die operative Anleitung für DAO, Risk Council
> und Core-Dev, welche numerischen Parameter existieren, wo sie gespeichert
> werden (Registry / Contracts) und wie sie sicher verändert werden können.

---

## 1. Rollenmodell

- **DAO / Timelock**
  - endgültige Entscheiderin für alle Parameter.
  - führt Änderungen über Governance-Proposals + Timelock aus.
- **Risk Council**
  - erarbeitet Vorschläge für Fees, Spreads, Limits und Oracle-Thresholds.
  - liefert Parameter-Sets inkl. Begründung / Risiko-Bewertung.
- **Core-Dev / Maintainer**
  - implementiert neue Parameter nur nach Governance-Beschluss.
  - stellt sicher, dass Tests und Docs den neuen Zustand widerspiegeln.
- **Guardian / SafetyAutomata**
  - reagiert auf Health-Signale (Oracle, PSM, externe Warnings).
  - pausiert Module bei kritischen Zuständen.

---

## 2. Parameterklassen – Überblick

Wir unterscheiden drei Hauptgruppen:

1. **Ökonomische Parameter (PSM Economic Layer)**
   - Fees, Spreads, Decimals.
2. **Risikoparameter (Oracle Health & Limits)**
   - Preis-Sprünge, Staleness, Volumen-Limits.
3. **Administrative Parameter**
   - Admin-Adressen, Registry-Zeiger, Guardian / Safety-Modul.

Alle wichtigen numerischen Parameter werden – wo möglich – über die
**ParameterRegistry** gesteuert, so dass nur ein kleiner Kern an
on-chain-Functions direkt geschrieben werden muss.

---

## 3. PSM – ökonomische Parameter

### 3.1 Decimals (DEV-47)

**Zweck:** Der PSM muss wissen, mit wie vielen Decimals ein Collateral-Token
arbeitet, um Beträge korrekt zu normalisieren.

- Registry-Key (globaler Namespace):
  - `psm:tokenDecimals`
- Per-Token-Key:
  - `keccak256(abi.encode("psm:tokenDecimals", token))`

**Auflösung:**

1. Wenn ein Eintrag für den adress-spezifischen Key existiert (`> 0`),
   wird dieser Wert als `decimals` verwendet.
2. Sonst wird auf **18 Decimals** zurückgefallen (Fallback, kompatibel
   mit den meisten ERC-20 und Kaspa-Wrappings).

**Governance-Richtlinie:**

- Für alle Collaterals **explizit** Decimals setzen.
- Fallback (18) nur für frühe Testphasen akzeptieren.
- Änderungen von Decimals erfordern in der Regel ein neues Asset-Setup
  (d.h. **kein** „live switch“ während aktivem Betrieb).

---

### 3.2 Fees (DEV-48)

**Zweck:** Einnahmen für Treasury / Reserve, Kompensation von
Markt- und Liquiditätsrisiken.

- Globale Registry-Keys:
  - `psm:mintFeeBps`
  - `psm:redeemFeeBps`
- Per-Token Overrides:
  - `keccak256(abi.encode("psm:mintFeeBps", token))`
  - `keccak256(abi.encode("psm:redeemFeeBps", token))`

**Resolution Order (Mint & Redeem):**

1. Per-Token Fee (`> 0`) → hat Vorrang.
2. Sonst globale Fee (`> 0`).
3. Sonst lokaler Storage im PSM (`mintFeeBps` / `redeemFeeBps`).
4. Falls alles 0 → effektive Fee = 0 bps.

**Safety-Invariante:**

- `feeBps <= 10_000` (max. 100 %).

**Typische Governance-Entscheidungen:**

- **Stable, sehr liquide Collaterals** → geringe Fees (z.B. 0–10 bps).
- **Riskantere Collaterals** → höhere Fees (z.B. 20–100 bps),
  zur Kompensation von Volatilität / Liquiditäts-Risiko.

---

### 3.3 Spreads (DEV-52)

**Zweck:** Feinsteuerung des Preisfensters, z.B. asymmetrische
Incentives für Mint vs. Redeem oder risikobasierte Zuschläge pro Asset.

- Globale Registry-Keys:
  - `psm:mintSpreadBps`
  - `psm:redeemSpreadBps`
- Per-Token Overrides:
  - `keccak256(abi.encode("psm:mintSpreadBps", token))`
  - `keccak256(abi.encode("psm:redeemSpreadBps", token))`

**Resolution Order:**

1. Per-Token Spread (`> 0`) → Vorrang.
2. Sonst globaler Spread (`> 0`).
3. Sonst implizit 0.

**Effektive Belastung:**

Für eine Transaktion gelten:

- Mint: `totalBps = mintFeeBps + mintSpreadBps`
- Redeem: `totalBps = redeemFeeBps + redeemSpreadBps`

**Safety-Invariante:**

- Der PSM erzwingt:
  - `feeBps + spreadBps <= 10_000`

**Governance-Patterns:**

- „Einbahn-Straße“ in Stressphasen:
  - z.B. Redeem-Spreads erhöhen, Mint-Spreads reduzieren,
    um Neumint zu fördern, aber massivausgänge zu bremsen.
- Asset-spezifische Anpassungen:
  - illiquide / riskante Collaterals mit dauerhaft höheren Spreads.

---

## 4. PSM – Volumen- und Tages-Limits (PSMLimits)

**Zweck:** Schutz gegen plötzliche Volumen-Spikes, die die Reserven
oder das System-Design überfordern.

Parameter werden nicht über die Registry, sondern über den separaten
`PSMLimits`-Contract verwaltet.

Typische Parameter:

- `singleTxCap` — maximale Notional-Größe pro Swap (in 1kUSD-Einheiten).
- `dailyCap` — maximales kumuliertes Tagesvolumen (ebenfalls in 1kUSD).

**Durchsetzung im PSM:**

- Bei jedem Swap wird der Notional in 1kUSD berechnet.
- `limits.checkAndUpdate(notional1k)` stellt sicher, dass:
  - keine Transaktion größer als `singleTxCap` ist,
  - die Summe aller Swaps eines Tages `dailyCap` nicht übersteigt.

**Governance-Richtlinien:**

- Start mit konservativen Caps (z.B. kleiner als tägliche
  On-Chain-Liquidität).
- Caps können nach oben angepasst werden, wenn:
  - Liquidität gewachsen ist,
  - die Oracle / Guardian / Safety-Pfade sich in der Praxis bewährt haben.

---

## 5. Oracle Health – Risikoparameter (DEV-49)

**Zweck:** Sicherstellen, dass der PSM nur mit „gesunden“ Preisen arbeitet.

Wesentliche Parameter:

- `oracle:maxDiffBps`
  - maximal erlaubter prozentualer Sprung zwischen zwei Preis-Updates.
- `oracle:maxStale`
  - maximale Zeit in Sekunden, die ein Preis alt sein darf, bevor er als
    „stale“ markiert wird.

**Wirkung im OracleAggregator:**

- Bei Updates / Reads werden Health-Checks ausgeführt:
  - Ist `age > maxStale` → `healthy = false`.
  - Ist Preis-Sprung > `maxDiffBps` → `healthy = false`.
- PSM verlangt `p.healthy == true`, sonst revertet der Swap.

**Governance-Richtlinien:**

- `maxDiffBps`:
  - enge Werte für Low-Volatility-Assets (z.B. 100–500 bps),
  - lockerere für High-Volatility-Assets (z.B. 1 000–2 000 bps),
    abhängig vom Feed-Design.
- `maxStale`:
  - kleiner als erwartetes Update-Intervall des Feeds,
    aber groß genug, um kurze Netz-Probleme zu tolerieren.

---

## 6. Administrative Parameter

### 6.1 Admin / Registry / Safety

- `OracleAggregator.admin`
  - darf Registry wechseln und Preise setzen (in der Mock-Phase),
    später nur noch indirekt durch Governance.
- `OracleAggregator.registry`
  - Zeiger auf `ParameterRegistry`; darf nur durch DAO / Timelock
    angepasst werden.
- `PSM.registry`
  - gleiche Logik: Admin-/DAO-gesteuerte Registry-Adresse.

- `SafetyAutomata` / `Guardian`
  - behalten modul-spezifische Pausen-Flags (z.B. `MODULE_PSM`,
    `MODULE_ORACLE`).

**Regel:**

- Jede Änderung von Admins oder Registry-Adressen **nur via Governance**
  (Timelock + Proposal), niemals via EOAs „per Hand“.

---

## 7. Praktische Governance-Playbooks

### 7.1 Beispiel: Fee-Anpassung für ein neues Collateral

1. Risk Council schlägt vor:
   - `mintFeeBps (global)` unverändert,
   - `mintFeeBps(token)` leicht erhöht,
   - `redeemFeeBps(token)` moderat.
2. Proposal:
   - Setzte per-Token Fee-Keys in der Registry.
3. Tests:
   - Dry-Run auf Testnet,
   - `PSMRegression_Fees` in CI grün.
4. Rollout:
   - Timelock → Execute → Monitoring (Volumen & Guardian-Status).

### 7.2 Beispiel: Aktivierung eines Redeem-Spreads in Stressphase

1. Oracle / Markets signalisieren Stress.
2. Governance-Beschluss:
   - `redeemSpreadBps(token)` auf z.B. 200 bps anheben.
3. Umsetzung:
   - Registry-Update,
   - Kommunikation an Nutzer (Frontends / Docs).
4. Deeskalation:
   - nach Stabilisierung schrittweise Reduktion des Spreads.

---

## 8. Referenz – Relevante Regression-Suites

- **`PSMRegression_Flows`**
  - end-to-end Mint / Redeem Flows mit realen Vault-Interaktionen.
- **`PSMRegression_Limits`**
  - Single-Tx- und Daily-Cap-Invarianten.
- **`PSMRegression_Fees`**
  - globale + token-spezifische Fee-Konfiguration.
- **`PSMRegression_Spreads`**
  - Spreads auf Mint- und Redeem-Seite (inkl. Overrides).
- **`OracleRegression_Health`**
  - `maxDiffBps` und `maxStale` Verhalten.
- **Guardian-Tests**
  - Propagation von Pausen/Unpausen in PSM und Oracle.

---

## Proposal-Template

Für formale Änderungsanträge zu PSM- und Oracle-Parametern kann folgendes JSON-Template verwendet werden:

- \`docs/governance/proposals/psm_parameter_change_template.json\`

Dieses Template beschreibt:
- Meta-Daten (ID, Netzwerk, Autor),
- Motivation und Risikoanalyse,
- konkrete Parameter-Änderungen (Fees, Spreads, Limits, Oracle-Health),
- sowie Governance- und Ausführungspfad.

### BuybackVault StrategyConfig (v0.51.0)

Die BuybackVault-Strategie erlaubt es dem DAO, zukünftige Buyback-Policies
vorzukonfigurieren, ohne den aktuellen Ausführungs-Flow zu verändern.

**Parameter (pro Strategie-Slot):**

- \`asset\` – Ziel-Asset (z.B. Governance- oder Treasury-Token)
- \`weightBps\` – Gewichtung in Basispunkten (0–10_000) für spätere Multi-Asset-Logik
- \`enabled\` – Flag, ob die Strategie für Auswertungen/Telemetrie aktiv ist

**Wichtige Hinweise für v0.51.0:**

- \`executeBuyback()\` ignoriert \`StrategyConfig\` aktuell vollständig.
- Strategien dienen ausschließlich als **Konfigurations- und Telemetrie-Basis**
  für künftige Erweiterungen (Multi-Asset, Scheduling, Policy-Module).
- Änderungen an Strategien sind DAO-only und sollten wie Parameter-Änderungen
  dokumentiert und versioniert werden.


