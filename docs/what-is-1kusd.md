# What is 1kUSD?

1kUSD is an open-source stablecoin protocol under development. Its intended
design is a token redeemable against approved on-chain collateral through a Peg
Stability Module (PSM).

## Intended reserve model

For every redeemable unit in circulation, the production design must account for
at least the approved collateral value required by the reserve and haircut policy.
No production policy or reserve attestation is active in this repository today.

## Intended peg mechanism

Users deposit approved collateral and receive 1kUSD after fees. They return 1kUSD
and receive collateral after fees. If external liquidity exists, this two-way
conversion can create arbitrage pressure toward the target price.

This mechanism is not an unconditional guarantee of a one-dollar market price.
It depends on collateral quality, liquidity, oracle integrity, limits, fees,
solvency, governance, and operational availability.

## Current control model

The prototype still has powerful admin-controlled components. The real governance
timelock is not implemented, the oracle is a mock, and the Guardian role flow has
open findings. Therefore it must not be described as ownerless or fully
decentralized today.

## Kaspa

Kaspa Toccata now supports covenant programmability. A Kaspa-native 1kUSD remains
a design project: token balances, global PSM state, oracles, roles, and pause
semantics cannot be copied directly from the EVM account model.

[How it works](how-it-works.md) · [Security](security.md) · [Roadmap](roadmap.md)
