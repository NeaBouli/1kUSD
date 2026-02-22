# How It Works

1kUSD keeps its peg through a simple, battle-tested mechanism: the **Peg Stability Module (PSM)**.

## The Simple Version

```
You deposit stablecoins  -->  You get 1kUSD
You return 1kUSD         -->  You get stablecoins back
```

That's it. No leverage, no debt, no complex mechanics.

## The Full Picture

The protocol has five core components working together:

### 1. Peg Stability Module (PSM)
The heart of the protocol. The PSM allows anyone to:

- **Mint**: Deposit USDC/USDT/DAI, receive 1kUSD (minus a 0.1% fee)
- **Redeem**: Return 1kUSD, receive collateral back (minus a 0.1% fee)

This two-way convertibility creates natural arbitrage that keeps the price at $1.

### 2. Collateral Vault
A smart contract that securely holds all deposited collateral. Only the PSM can withdraw from the vault — no admin, no backdoor.

### 3. Oracle Aggregator
Reads prices from multiple oracle feeds and calculates a safe median price. If feeds go stale or disagree too much, the system automatically pauses to protect users.

### 4. Safety Automata
The protocol's immune system. It monitors all operations and can:

- Pause specific modules if something looks wrong
- Enforce rate limits (daily caps, per-transaction caps)
- Automatically expire emergency controls (guardian sunset)

### 5. DAO Governance
All protocol parameters (fees, caps, oracle settings) are stored on-chain and can only be changed through a DAO with a timelock — giving users advance notice before any change takes effect.

## Mint Flow

```
User                    PSM                    Vault               Token
  |                      |                      |                    |
  |--- deposit USDC --->|                      |                    |
  |                      |--- store USDC ----->|                    |
  |                      |--- mint 1kUSD -------------------------------->|
  |<--- receive 1kUSD --|                      |                    |
```

## Redeem Flow

```
User                    PSM                    Vault               Token
  |                      |                      |                    |
  |--- send 1kUSD ----->|                      |                    |
  |                      |--- burn 1kUSD -------------------------------->|
  |                      |--- withdraw USDC ---|                    |
  |<--- receive USDC ---|                      |                    |
```

## What Keeps the Peg?

**Arbitrage.** If 1kUSD trades at $0.99 on a DEX, anyone can:

1. Buy 1kUSD at $0.99
2. Redeem it through the PSM for $1.00 of USDC
3. Pocket the $0.01 profit per token

This buying pressure pushes the price back to $1. The reverse works if 1kUSD trades above $1.

---

[Why 1kUSD?](why-1kusd.md) | [Security](security.md) | [Roadmap](roadmap.md) | [Back to Home](INDEX.md)
