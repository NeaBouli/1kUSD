# Security Analysis Plan — Specification
**Status:** Spec (no code). **Language:** EN.

## Threat Model
- Auth bypass, reentrancy, oracle manipulation, cap/limit bypass, governance capture, guardian misuse, pause evasion
- ERC-20 quirks: fee-on-transfer, decimals change

## Analysis Stack
- Static: Slither, Mythril
- Property Fuzz: Echidna/Foundry invariants
- Manual Review: authZ, decimals/rounding, CEI, events, guardian sunset
- Deps Review: tokens/routers/oracles adapters

## Severity
- Critical / High / Medium / Low-Info

## Deliverables
- reports/security-findings.json (per reports/SCHEMA.md)
- Summary in CHANGELOG; re-test after fixes

## Exit Criteria
- No Critical/High open; Medium mitigated/accepted
