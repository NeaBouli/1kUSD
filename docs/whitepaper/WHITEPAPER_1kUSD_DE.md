# 📘 1kUSD Whitepaper (Deutsch)
*Version 1.0 – Oktober 2025*  
*Lizenz: AGPL-3.0*

## 1. Abstract

## Oracle Regression Stability — DEV-41

This release consolidates the stability of the OracleWatcher, OracleAggregator,
and Oracle propagation paths. It resolves ZERO_ADDRESS initialization issues,
restores correct inheritance chains, and ensures refreshState() behaves consistently.

Full report: **docs/reports/DEV41_ORACLE_REGRESSION.md**

**1kUSD** ist ein vollständig dezentraler, on-chain besicherter und algorithmisch stabilisierter Stablecoin (EVM-Start, Kasplex/Kaspa-Pfad). Ziel: **1:1 USD-Peg** ohne zentrale Verwahrung – mit **Vault (Stablecoins)**, **PSM (1:1-Swap)**, **AutoConverter** (volatile → stable), **Oracle-Median**, **Safety-Automata** (Rate-Limiter, Circuit-Breaker), **DAO/Timelock** (Governance).

## 2. Problem
Zentrale Stablecoins (USDT/USDC) dominieren, sind custodial und einfrierbar. Kaspa-Ökosystem fehlt ein **nativ dezentraler** USD-Peg mit **on-chain Proof-of-Reserves**.

## 3. Lösung (Überblick)
- **On-Chain Module:** Token, CollateralVault, AutoConverter, PSM, OracleAggregator, Safety-Automata, DAO/Timelock, Treasury, Bridge-Anker (Vorbereitung).
- **Peg-Mechanik:** PSM erlaubt 1kUSD ↔ Stablecoins (nahe 1:1, geringe Fee). Arbitrage hält Marktpreis bei ≈1 USD.  
- **Deckung:** Vault hält überwiegend **USDT/USDC/DAI**; optional konvertierte volatile Assets via AutoConverter.  
- **Transparenz:** On-chain Proof-of-Reserves, Indexer/Explorer.

## 4. Architektur
**Textschema:**  
Benutzer/Wallet → RPC/SDK → PSM / AutoConverter → **CollateralVault** ↔ **1kUSD Token** ↔ DEX/AMM  
CollateralVault ← OracleAggregator (Health/Median) ← Safety-Automata (Policies)  
DAO/Timelock → Parameter (PSM-Fee, Caps, Oracles, Limits)  
Bridge-Anker (später) ↔ Kasplex/Kaspa

**Kernmodule (Funktionen):**
- **1kUSD Token:** ERC-20, mint/burn ausschließlich durch Protokoll-Module.  
- **CollateralVault:** Verwahrt Stablecoins, nur Protokollpfade für Ein/Ausgänge, Exposure-Caps.  
- **AutoConverter:** Nimmt volatile Assets an, routet best-execution zu Stablecoins → Vault.  
- **PSM:** 1:1-Swap 1kUSD↔Stablecoin (Fee ~0,1%), Rate-Limiter, Caps, Pause-fähig.  
- **OracleAggregator:** Multi-Feed Median (Chainlink/Pyth/TWAP), Deviation/Staleness-Guards.  
- **Safety-Automata:** Pausieren/Wiederaufnehmen, Caps, Rate-Limits, kein Asset-Zugriff.  
- **DAO/Timelock:** Param-Updates mit Verzögerung; Phase-2 optional Governance-Token.  
- **Treasury:** Gebührensenke; Ausgaben nur via DAO.  
- **Bridge-Anker (Prep):** Message/Proof-Spec für Kasplex/Kaspa.

## 5. Mechanismen
### 5.1 CollateralVault
- Akzeptiert Stablecoins (USDT/USDC/DAI).  
- Proof-of-Reserves: on-chain Views/Events.  
- Exposure-Caps pro Asset; pausierbar.

### 5.2 AutoConverter
- Unterstützt eingehende **volatile Assets** (über Wrapper/Bridges).  
- Best-Execution via DEX/Aggregator-Adapter (Slippage-Limits).  
- Output **immer** Stablecoin → Vault.

### 5.3 Peg-Stability-Module (PSM)
- 1:1-Swap 1kUSD ↔ Stablecoin; geringe Fee; Rate-Limiter; Caps.  
- Oracle-Deviation-Guard (bei Anomalien pausieren).

### 5.4 OracleAggregator
- Median über mehrere Feeds; Stale- und Deviation-Checks.  
- Finality-aware (Reorg-Sicherheit).

### 5.5 Safety-Automata
- Setzt Caps/Rate-Limits; pausiert Module; **keine** Asset-Kontrolle.  
- Optionaler Guardian-Multisig mit **Sunset**; primär Timelock-gesteuert.

## 6. Ökonomie & Stabilität
- **Deckung:** \(\sum_i C_i \cdot P_i\) ≥ zirkulierende 1kUSD.  
- **Arbitrage:**  
  - 1kUSD < 1 USD → Kauf am Markt → PSM-Redeem zu 1 USD.  
  - 1kUSD > 1 USD → PSM-Mint → Verkauf >1 USD.  
- **Formel (Wertuntergrenze):**  
  \( V_{1kUSD} = \min\left(1,\; \frac{\sum_i C_i \cdot P_i}{S}\right) \)  
  mit \(C_i\) Collateral-Mengen, \(P_i\) USD-Preis, \(S\) Supply.

## 7. Sicherheit
- Ownerless/Timelock-Kontrolle; **keine EOA-Owner**.  
- Invarianten: Supply ≤ Reserves; Pause-aware Funktionen.  
- Audits: Static-Analysis, Fuzzing, externe Audits; Responsible Disclosure.  
- Monitoring/Alerts: Peg-Drift, Oracle-Stale, Cap-Nutzung, Pausenstatus.

## 8. Governance
- **Phase 1:** DAO ohne Token (Stimmrechte an definierte Adressen/1kUSD-Halter), Timelock 48–96h.  
- **Phase 2 (optional):** Governance-Token (z. B. KASDAO) mit klaren Zuständigkeiten, unverändert on-chain.

## 9. Rechtliches (Kurz)
- Dezentral, open-source, non-custodial, keine Renditeversprechen → geringere Regulierungslast.  
- Orientierung an DAI-Prinzipien, weitergehend mit **Safety-Automata** & **Ownerless-Design**.

## 10. Implementierungs-Bauplan
**Ordner:** `contracts/` (Module), `interfaces/` (IDL/ABIs), `docs/`, `arch/`, `tasks/`, `patches/`, `reports/`, `logs/`.  
**Schnittstellen (Beispiele):**  
- PSM: `swapTo1kUSD(tokenIn, amountIn)` / `swapFrom1kUSD(tokenOut, amountIn)`  
- Oracle: `getPrice(asset)`, `isHealthy(asset)`, `lastUpdate(asset)`  
- Safety: `pause(module)`, `resume(module)`, `setCap(asset, cap)`

## 11. Roadmap
1) **EVM-Start** (Testnet → Mainnet)  
2) **DAO-Upgrade** (Phase-2 optional)  
3) **Kasplex-Bridge** (Prep → Test → Prod)  
4) **Kaspa L1** (bei VM-Verfügbarkeit)  
5) **Ökosystem-Ausbau** (DEX/AMM, Lending, Integrationen)

## 12. Schluss
**1kUSD** vereint Stabilität, Dezentralität und Transparenz mit klaren Sicherheits- und Governance-Mechanismen als Grundlage eines Kaspa-kompatiblen DeFi-Stacks.
