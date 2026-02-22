# Security

1kUSD is built with a **security-first** philosophy. Every component is designed to fail safely.

## Battle-Tested Before Launch

| Metric | Value |
|--------|-------|
| Automated tests | **198** |
| Test suites | **35** |
| Protocol invariants | **35** |
| Fuzz test runs | **256 runs x 64 depth** |
| Economic simulations | **10 scenarios** |
| Audit documents | **11** |

## Defense in Depth

### Oracle Guards
The protocol reads prices from multiple oracle feeds. If feeds go stale or disagree beyond acceptable limits, the system automatically pauses — no user funds are at risk from manipulated prices.

### Rate Limits
Every swap through the PSM is subject to:

- **Daily volume cap** — limits total daily minting/redeeming
- **Per-transaction cap** — prevents single large exploits

### Circuit Breakers
The Safety Automata can instantly pause any module if anomalies are detected. This is a last line of defense that prevents cascading failures.

### Guardian Sunset
An emergency Guardian can pause the system to protect users, but it:

- **Cannot move any funds**
- **Automatically expires** after a set period
- **Can be overridden** by the DAO

### DAO Timelock
All parameter changes go through a timelock — users always have advance notice before any protocol change takes effect.

## Audit Package

The complete audit documentation is publicly available:

- Audit Scope and file manifest
- 35 protocol invariants with coverage matrix
- 5 economic risk scenarios with mitigations
- Threat model (10 attack classes)
- Trust model and role matrix
- Known limitations (12 documented)

For full technical details, see the [Technical Wiki](https://github.com/NeaBouli/1kUSD/wiki).

## Open Source

Every line of code is open source under AGPL-3.0. Anyone can review, audit, or fork the protocol.

Repository: [github.com/NeaBouli/1kUSD](https://github.com/NeaBouli/1kUSD)

---

[How It Works](how-it-works.md) | [Roadmap](roadmap.md) | [Back to Home](INDEX.md)
