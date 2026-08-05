# How the mechanism is intended to work

## Mint

```text
user collateral
    -> validate asset, amount, limits, deadline, oracle and pause state
    -> transfer collateral to the vault
    -> reconcile the actual received amount
    -> calculate price, fees and rounding
    -> mint net 1kUSD to the recipient
```

## Redeem

```text
user 1kUSD
    -> validate asset, amount, limits, deadline, oracle and pause state
    -> burn the user's input
    -> calculate collateral output and fees
    -> transfer collateral from the vault
    -> reconcile reserve and fee accounting
```

## Components

| Component | Responsibility | Prototype caveat |
|---|---|---|
| `OneKUSD` | Token supply and transfers | Production administration not finalized |
| `PegStabilityModule` | Mint/redeem math and orchestration | Config fallbacks and fee path need hardening |
| `CollateralVault` | Reserve custody and accounting | Non-standard asset accounting needs policy/fix |
| `OracleAggregator` | Price interface and health | Current prices are admin-set mocks |
| `PSMLimits` | Per-operation and daily limits | Production configuration must be mandatory |
| `SafetyAutomata` | Module pause state | Sunset role precedence has an open blocker |
| `Guardian` | Time-limited pause operator | Registration/resume flow has an open blocker |
| `DAO_Timelock` | Delayed governance | Stub; execution is not implemented |
| Fee router / treasury | Fee accounting and destination | Interfaces and wiring are incomplete |

## What can keep the peg?

PSM arbitrage can help only when conversion is available and credible. A
production system also requires sufficient reserves, high-quality collateral,
reliable pricing, external liquidity, bounded governance, monitoring, and tested
incident behavior.

The current repository demonstrates parts of this mechanism; it does not yet
provide the complete production system.

[Security](security.md) · [Roadmap](roadmap.md) · [Home](index.md)
