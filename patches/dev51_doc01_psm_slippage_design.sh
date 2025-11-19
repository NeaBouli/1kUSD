#!/usr/bin/env bash
set -euo pipefail

FILE="docs/economics/psm_slippage_design.md"

echo "== DEV51 DOC01: write PSM slippage & spread design doc =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# PSM Slippage, Spread & Fee Design (DEV-51)

> Status: Design-Spezifikation (noch keine Implementierung)  
> Scope: Nur 1kUSD PSM, EVM-Variante, aber Kaspa-L1-kompatibel gedacht.

## 1. Ziele

Die Slippage-/Spread-Logik des PSM soll:

- den Peg von 1kUSD eng um 1.00 halten,
- extreme Orderflow-Spitzen dämpfen,
- Manipulation (Oracle + Low-Liquidity) erschweren,
- für Auditoren klar nachvollziehbar sein,
- auf Kaspa L1 mit minimalen Anpassungen portierbar bleiben.

Wir unterscheiden klar:

1. **Notional-Layer** (DEV-44):  
   Rechnet alle Swaps in 1kUSD-Notional mit 18 Decimals.

2. **Fee-Layer** (DEV-48):  
   Wendet eine prozentuale Fee auf die Notional-Size an (mint/redeem).

3. **Spread-/Slippage-Layer (dieses Dokument, DEV-51)**:  
   Modifiziert den effektiven Preis / die effektive Out-Menge abhängig von
   Richtung (mint vs. redeem), Größe und Marktbedingungen.

---

## 2. Begriffe

- **Mid-Price (Mid)**  
  Der neutrale Referenzpreis aus dem Oracle (nach Health-Gates),
  interpretiert als „fairer Marktpreis“.

- **Spread**  
  Abweichung vom Mid-Price je nach Richtung:
  - `mint` (COL → 1kUSD): typischerweise etwas *unter* Mid (User bezahlt Aufschlag),
  - `redeem` (1kUSD → COL): typischerweise etwas *über* Mid (User bekommt etwas weniger).

- **Slippage-Kurve**  
  Eine Funktion, die den effektiven Preis abhängig von der Notional-Size
  leicht in die für das System vorteilhafte Richtung verschiebt.
  Beispiel: kleine Swaps ≈ Mid, große Swaps → schlechterer Kurs.

---

## 3. Architektur-Skizze

Wir führen einen **zusätzlichen Layer** ein, der auf der bereits vorhandenen
Notional-Berechnung aufsetzt:

1. Oracle liefert `price` (+ decimals) und ist per Health-Gates abgesichert.
2. PSM rechnet `amountToken → amount1k` (Notional-Layer).
3. Slippage/Spread-Layer modifiziert:
   - für Mints: den effektiven 1kUSD-Out,
   - für Redeems: den effektiven Token-Out.
4. Fee-Layer (DEV-48) wendet danach Gebühren an (oder davor, siehe unten).
5. Limits (PSMLimits) gelten weiterhin auf 1kUSD-Notional, *vor* Spread/Fee.

Wichtiger Punkt:  
**Limits sind Peg-sicher, Spread ist markt-/risikotechnisch.**

---

## 4. Parameter-Design (Registry + Limits)

Wir nutzen den bereits etablierten `ParameterRegistry`-Ansatz:

### 4.1 Globale Spread-Parameter

- `psm:spreadMintBps`  
  - Basisspread in Basis-Punkten auf Mint-Seite.
  - Interpretiert als Aufschlag auf den Notional-Preis (User zahlt mehr).
  - Beispiel: 20 bps → User erhält effektiv 0,998 des idealen Mid-Outputs.

- `psm:spreadRedeemBps`  
  - Basisspread in Basis-Punkten auf Redeem-Seite.
  - Interpretiert als Abschlag auf den Collateral-Out (User bekommt weniger).
  - Beispiel: 30 bps → User erhält 0,997 des idealen Collateral-Outputs.

### 4.2 Per-Token Overrides

Analog zu den Fee-Overrides:

- `psm:spreadMintBps:token`  
  - Key-Schema: `keccak256(abi.encode(KEY_SPREAD_MINT_BPS, token))`.

- `psm:spreadRedeemBps:token`  
  - Key-Schema: `keccak256(abi.encode(KEY_SPREAD_REDEEM_BPS, token))`.

Auflösung:

1. Wenn per-Token Spread > 0 → benutze diesen.
2. Sonst globaler Spread > 0 → benutze diesen.
3. Sonst: Spread = 0 (neutral, entspricht aktuellem Verhalten).

Alle Pfade müssen `<= 10_000` sicherstellen (max. 100 % Spread).

---

## 5. Rechen-Reihenfolge: Spread vs. Fee

Es gibt zwei natürliche Reihenfolgen:

1. **Spread zuerst, dann Fee**  
   - Effektiv: Basispreis wird verschlechtert, dann prozentuale Fee darauf.
   - Vorteil: Risiken/Marktverzerrungen werden in Preis eingepreist,
     Fees spiegeln „volumenbasierte Einnahmen“ wider.

2. **Fee zuerst, dann Spread**  
   - seltener, ökonomisch schwerer zu argumentieren.

Empfohlene Reihenfolge für 1kUSD (DEV-51 Design):

- **Mint:**
  1. Notional bestimmen (`notional1k`),
  2. Spread anwenden → `notionalAfterSpread`,
  3. Fee anwenden → `net1k`,
  4. Limits auf ursprünglichem `notional1k` (wie bisher).

- **Redeem:**
  1. Eingehenden 1kUSD-Betrag als `notional1k` interpretieren,
  2. Fee anwenden → `net1k`,
  3. Spread anwenden → `netTokenOut`,
  4. Limits auf ursprünglichem `notional1k`.

Begründung:

- Mint-Seite: User „kauft“ 1kUSD → Spread wirkt wie „Market-Maker-Marge“.
- Redeem-Seite: Fee reduziert zuerst 1kUSD-Notional, Spread reflektiert
  zusätzliche Marktfriktionen bei der Collateral-Auszahlung.

---

## 6. Slippage als Funktion der Ordergröße

Neben einem statischen Spread kann eine einfache Slippage-Funktion
definiert werden, z.B. in Form diskreter Buckets:

- `psm:slippageBucket1Notional` (z.B. 10_000e18)  
- `psm:slippageBucket1Bps` (z.B. 5 bps)

- `psm:slippageBucket2Notional` (z.B. 100_000e18)  
- `psm:slippageBucket2Bps` (z.B. 20 bps)

- `psm:slippageBucket3Notional` (z.B. 1_000_000e18)  
- `psm:slippageBucket3Bps` (z.B. 50 bps)

Einfache Logik:

- Wenn `notional1k <= Bucket1` → `slippageBps = Bucket1Bps`,
- Wenn `Bucket1 < notional1k <= Bucket2` → `slippageBps = Bucket2Bps`,
- Wenn `notional1k > Bucket2` → `slippageBps = Bucket3Bps`.

Diese Slippage-Bps können einfach **additiv** zum Spread addiert werden:

- `effectiveMintBps = spreadMintBps + slippageBps`
- `effectiveRedeemBps = spreadRedeemBps + slippageBps`

Das gesamte Konstrukt bleibt:

- hinter der Oracle-Health-Schicht,
- vor dem Fee-Layer (Mint) bzw. nach dem Fee-Layer (Redeem),
- vollständig über Registry-Parameter steuerbar.

---

## 7. Governance & Risk-Playbook (High-Level)

### 7.1 Standard-Setup

- Kleine Retail-Swaps:
  - Spread ~ 0–10 bps,
  - Slippage minimal oder 0.

- Große Swaps:
  - Spread + Slippage signifikant höher (20–100 bps),
  - schützt Treasury und Peg.

### 7.2 Notfall-Setup

In Stressphasen (z.B. Oracle unsicher, hoher Abfluss):

- Guardian/Safety könnte:
  - PSM komplett pausieren,
  - oder Governance temporär die Spread-/Slippage-Parameter anheben:
    - höhere Redeem-Spreads,
    - aggressive Slippage auf große Swaps.

### 7.3 Kaspa-L1 Implikationen

Da die Logik rein arithmetisch ist und auf Registry-Keys basiert, ist die
Migration auf Kaspa L1:

- Implementierbar in jeder Contract-/Script-Sprache,  
- unabhängig von ERC-20 intern,
- mit identischem Parameternamen-/Key-Schema.

---

## 8. Nächste Schritte (DEV-52+)

DEV-51 definiert **nur das Design**. Konkrete Implementierungs-Vorschläge:

1. Neue Helper im PSM:
   - `_resolveMintSpreadBps(token)`,
   - `_resolveRedeemSpreadBps(token)`,
   - `_resolveSlippageBps(notional1k)`.

2. Anpassung der `_computeSwapTo1kUSD` / `_computeSwapFrom1kUSD`, um:
   - Spread- und Slippage-Bps in effektive Notional-/Token-Mengen einzupreisen,
   - Fees weiterhin über den existierenden Fee-Layer zu behandeln.

3. Erweiterung der Regression-Suiten:
   - `PSMRegression_Flows`: Tests für große vs. kleine Swaps,
   - `PSMRegression_Fees`: Interaktion feeBps + spread/ slippageBps,
   - zusätzliche Tests für Fairness/Symmetrie über beide Richtungen.

EOL

echo "✓ PSM slippage & spread design doc written to $FILE"
