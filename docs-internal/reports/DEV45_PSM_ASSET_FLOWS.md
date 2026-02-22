# DEV-45 — PSM Asset Flows & Fee Routing (Design Skeleton)

_Status: planned — this file is a skeleton and will be filled once DEV-45 patches land._

## Scope

- Connect PegStabilityModule to real asset flows (Vault + 1kUSD).
- Implement asymmetrical fees (mint vs redeem) on 1kUSD notional base.
- Prepare hooks for future KAS / KRC-20 migration (collateral slot design, legacy vs primary).

## Notes

- Price-normalized notional math from DEV-44 is the invariant layer.
- DEV-45 must not change the IPSM interface or notional semantics.
