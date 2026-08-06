# Why build 1kUSD?

Stable units of account can support payments, markets, treasury accounting, and
DeFi. The design question is not whether a stablecoin is useful, but whether its
collateral, redemption, governance, oracle, liquidity, and operational risks are
explicit and independently verifiable.

## Proposed differentiators

- fully collateralized PSM model rather than user CDP debt;
- transparent reserve and liability accounting;
- bounded mint/redeem exposure;
- fail-closed oracle and asset configuration;
- limited emergency authority and delayed governance;
- open implementation, tests, threat model, and release evidence;
- a Kaspa-primary implementation informed by portable invariants and failure
  cases from the executable EVM reference.

## What is not true yet

The current prototype is not fully decentralized, cannot claim production
redemption, has no live proof-of-reserves system, uses a mock oracle, and has not
completed an external audit. These are roadmap outcomes, not current features.

## Why Kaspa?

Toccata's evolving covenant stack makes native application research possible on
Kaspa. Its UTXO model may support explicit reserve and issuance transitions, but
global PSM state, limits, oracles, governance, and indexing require a new
architecture. The project will validate that design on a currently supported
test network before making any native-launch claim.

[Project status](what-is-1kusd.md) · [Roadmap](roadmap.md) · [Home](index.md)
