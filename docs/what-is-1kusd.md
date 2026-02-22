# What is 1kUSD?

**1kUSD** is a decentralized stablecoin — a digital currency designed to always be worth exactly **1 US Dollar**.

Unlike centralized stablecoins like USDT or USDC, 1kUSD is not controlled by any single company. Instead, it runs entirely on smart contracts — transparent, open-source code that anyone can verify.

## How is it backed?

1kUSD is backed 1:1 by approved stablecoins (USDC, USDT, DAI) held in on-chain vaults. Every 1kUSD in circulation has at least $1 worth of collateral behind it.

There is no fractional reserve. No leverage. No CDP-style debt positions that can be liquidated.

## How does the peg work?

1kUSD uses a **Peg Stability Module (PSM)** — a smart contract that allows anyone to:

- **Mint**: Deposit $1 of stablecoins, receive 1 1kUSD (minus a small fee)
- **Redeem**: Return 1 1kUSD, receive $1 of stablecoins (minus a small fee)

This creates a natural arbitrage opportunity. If 1kUSD trades below $1, traders can buy it cheaply and redeem it for $1. If it trades above $1, traders can mint new 1kUSD and sell it. This keeps the price pegged at $1.

## Who controls it?

No single person or company controls 1kUSD. Protocol parameters (fees, caps, oracle settings) are governed by a **DAO with timelock** — any change requires a waiting period before it takes effect, giving users time to react.

A temporary **Guardian** can pause the system in emergencies, but the Guardian automatically expires (sunset) and cannot move any funds.

## Why does the Kaspa ecosystem need this?

The Kaspa network is a high-throughput, GHOSTDAG-powered BlockDAG — one of the fastest proof-of-work networks. But every blockchain ecosystem needs a stable unit of account for:

- Payments and commerce
- DeFi applications (lending, liquidity pools)
- Cross-chain value transfer
- A safe harbor during market volatility

1kUSD is designed to be that foundation — starting on Ethereum and migrating to native KASPA when the smart contract layer is ready.

---

[How It Works (detailed)](how-it-works.md) | [Why 1kUSD?](why-1kusd.md) | [Back to Home](INDEX.md)
