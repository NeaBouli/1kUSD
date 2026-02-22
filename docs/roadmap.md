# Roadmap

1kUSD is on a path from ERC-20 stablecoin to **native KASPA stablecoin**.

---

## Phase 1: ERC-20 on Ethereum (Current)
**Version: v0.51.x**

- Full protocol implementation on Ethereum
- 198 automated tests (unit, fuzz, invariant, economic simulation)
- 35 protocol invariants verified
- Complete audit documentation package (11 documents)
- Sepolia testnet deployment pipeline
- Monitoring and health check infrastructure

**Status:** Audit-ready. All systems tested and documented.

---

## Phase 2: Mainnet Launch
**Version: v0.52.x (Planned)**

- Functional DAO Timelock with full governance
- Chainlink oracle integration (production feeds)
- FeeRouter v2 with enhanced fee distribution
- Multisig deployment and admin controls
- Bug bounty program activation
- DEX liquidity provisioning

---

## Phase 3: KASPA Exploration
**Version: v0.6x (Research)**

- KASPA smart contract layer evaluation
- Bridge architecture design
- Cross-chain asset transfer protocol
- Indexer finality watermark adaptation
- Community governance for migration parameters

---

## Phase 4: Native KASPA
**Version: v1.0 (Vision)**

- **Native 1kUSD on KASPA BlockDAG**
- Full PSM + Oracle + Safety stack on KASPA
- KASPA-native proof of reserves
- High-throughput settlement leveraging GHOSTDAG
- Ecosystem integration (KASPA DEXs, wallets, dApps)

---

The protocol architecture is **chain-agnostic by design**. The PSM, oracle, and safety layers are modular abstractions that can be re-implemented on any EVM-compatible or KASPA-native runtime.

---

Follow progress: **[@Kaspa_USD on X](https://x.com/Kaspa_USD)** | [GitHub](https://github.com/NeaBouli/1kUSD)
