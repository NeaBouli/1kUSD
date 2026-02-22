# Why 1kUSD?

## The Problem

Centralized stablecoins dominate the market, but they come with risks:

- **Custody risk** — a company holds your funds and can freeze them
- **Regulatory risk** — a government order can block access
- **Opacity** — you trust a company's word that reserves exist

Existing decentralized alternatives like DAI use CDP (Collateralized Debt Position) models that expose users to **liquidation risk** — your position can be forcefully closed during market stress.

## How 1kUSD is Different

| Feature | USDT/USDC | DAI | **1kUSD** |
|---------|-----------|-----|-----------|
| Decentralized | No | Partially | **Yes** |
| Can be frozen | Yes | No | **No** |
| Liquidation risk | N/A | Yes (CDP) | **No (PSM)** |
| On-chain reserves | No | Partially | **Yes** |
| Open source | No | Yes | **Yes** |
| Safety circuit breakers | N/A | Limited | **Yes** |
| KASPA-native path | No | No | **Yes** |

## Key Advantages

### 1. No Custody, No Freeze
1kUSD reserves are held in smart contracts, not by a company. No single entity can freeze your tokens or block redemptions.

### 2. No Liquidation Risk
Unlike CDP-based stablecoins, 1kUSD uses a **convert-on-deposit** model. You deposit stablecoins, you get 1kUSD. There is no debt position that can be liquidated.

### 3. Safety-First Architecture
The protocol includes multiple layers of protection:

- **Oracle guards** — stale or manipulated price feeds automatically pause operations
- **Rate limits** — daily and per-transaction caps prevent large-scale exploits
- **Circuit breakers** — the system can be paused instantly if anomalies are detected
- **Guardian sunset** — emergency controls automatically expire

### 4. Fully Transparent
Every component is open-source. The audit package includes 11 documents covering invariants, threat models, economic risks, and known limitations — all publicly available.

### 5. Built for KASPA
1kUSD is designed with KASPA in mind from day one. The protocol architecture is modular and chain-agnostic, ready to migrate when KASPA's smart contract layer supports it.

---

[How It Works](how-it-works.md) | [Security](security.md) | [Back to Home](INDEX.md)
