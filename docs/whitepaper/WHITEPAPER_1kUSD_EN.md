# 📘 1kUSD Whitepaper (English)
*Version 1.0 — October 2025*  
*License: AGPL-3.0*

## 1. Abstract
**1kUSD** is a fully decentralized, on-chain collateralized, algorithmically stabilized stablecoin (EVM first, Kasplex/Kaspa path). Target: **1:1 USD peg** without centralized custody — via **Vault (stablecoins)**, **PSM (1:1 swap)**, **AutoConverter** (volatile → stable), **Oracle median**, **Safety-Automata** (rate limits, circuit breaker), and **DAO/Timelock** governance.

## 2. Problem
Centralized stablecoins dominate (custodial, freeze risks). The Kaspa ecosystem lacks a **natively decentralized** USD peg with **on-chain proof-of-reserves**.

## 3. Solution (Overview)
- **On-Chain:** Token, CollateralVault, AutoConverter, PSM, OracleAggregator, Safety-Automata, DAO/Timelock, Treasury, Bridge Anchor (prep).  
- **Peg:** PSM allows 1kUSD ↔ stablecoins near 1:1 with a small fee; arbitrage enforces ≈1 USD.  
- **Reserves:** Vault primarily holds **USDT/USDC/DAI**; optionally converted volatile assets via AutoConverter.  
- **Transparency:** On-chain proofs and explorer views.

## 4. Architecture
**Text schema:**  
Wallet → RPC/SDK → PSM / AutoConverter → **CollateralVault** ↔ **1kUSD Token** ↔ DEX/AMM  
CollateralVault ← OracleAggregator (health/median) ← Safety-Automata (policies)  
DAO/Timelock → parameters (PSM fee, caps, oracles, limits)  
Bridge Anchor (later) ↔ Kasplex/Kaspa

**Core modules:** Token (ERC-20, protocol-only mint/burn), Vault (stablecoins + caps), AutoConverter (best-execution to stable), PSM (1:1 swap, fee, caps), Oracle (median, stale/deviation guards), Safety (pause/resume, caps, rate limits; no asset custody), DAO/Timelock, Treasury, Bridge Anchor (spec).

## 5. Mechanisms
- **Vault:** Stablecoin custody; on-chain views; asset exposure caps.  
- **AutoConverter:** Adapters to DEX/aggregators; slippage-bounded best execution to stable → Vault.  
- **PSM:** 1:1 swaps; small fee; rate limits; caps; pause on anomalies (oracle guard).  
- **Oracle:** Multi-feed median; stale/deviation checks; finality-aware.  
- **Safety-Automata:** Central policy enforcement; cannot move assets; optional guardian sunset.

## 6. Economics & Stability
- **Coverage:** \(\sum_i C_i \cdot P_i \geq S\).  
- **Arbitrage:**  
  - Price < 1 → buy and redeem via PSM at 1 USD.  
  - Price > 1 → mint via PSM and sell above 1.  
- **Lower bound:**  
  \( V_{1kUSD} = \min\left(1,\; \frac{\sum_i C_i \cdot P_i}{S}\right) \).

## 7. Security
Ownerless/Timelock control; invariants (supply ≤ reserves; pause-aware ops); audits (static/fuzz/external); monitoring & alerting (peg drift, oracle staleness, caps, pauses).

## 8. Governance
Phase 1: DAO without token (timelock 48–96h).  
Phase 2 (optional): governance token with clear responsibilities; immutable on-chain changes.

## 9. Legal (brief)
Decentralized, open-source, non-custodial, no yield promises → reduced regulatory exposure; DAI-like principles, extended with Safety-Automata & ownerless design.

## 10. Implementation Plan
Folders: `contracts/`, `interfaces/`, `docs/`, `arch/`, `tasks/`, `patches/`, `reports/`, `logs/`.  
Interfaces (examples):  
- PSM: `swapTo1kUSD(tokenIn, amountIn)` / `swapFrom1kUSD(tokenOut, amountIn)`  
- Oracle: `getPrice(asset)`, `isHealthy(asset)`, `lastUpdate(asset)`  
- Safety: `pause(module)`, `resume(module)`, `setCap(asset, cap)`

## 11. Roadmap
EVM launch → DAO upgrade → Kasplex bridge → Kaspa L1 (when available) → ecosystem expansion.

## 12. Conclusion
**1kUSD** combines stability, decentralization and transparency with rigorous safety and governance — a foundation for a Kaspa-compatible DeFi stack.
