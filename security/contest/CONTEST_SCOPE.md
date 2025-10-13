# Security Contest — Scope
**Status:** Info (no code). **Language:** EN.

## Included (in scope)
- Smart contracts (specs in `contracts/specs/*`): Token, PSM, CollateralVault, OracleAggregator, SafetyAutomata, DAO/Timelock, Treasury, ParameterRegistry, Rate-Limits.
- Cross-module flows: mint/redeem, fees, caps, rate-limits, pause, governance parameter changes.
- Math/rounding (decimals 6/18), fee accounting, event integrity.
- Indexer reconciliation assumptions (finality marks), not code.

## Excluded (out of scope)
- UI front-end code (no code in repo), partner infra, third-party bridges (unless adapter spec deviation).
- Dos by spamming mempool/RPC, chain-level faults, L2 insolvency.
- Social engineering, phishing.

## Severity Model (reference)
- Critical: direct loss of funds or unbounded inflation (supply > reserves).
- High: temporary loss/unavailability; bypass of core controls (caps, rate-limit, pause).
- Medium: accounting drift, oracle policy bypass without fund loss.
- Low/Info: gas inefficiencies, style, non-security docs.

## Impact Examples
- Critical: mint without deposit; withdraw from Vault sans Timelock; fee drain to attacker.
- High: bypass rate-limit/caps; pause evasion post-sunset; oracle guard bypass enabling unsafe mint.
