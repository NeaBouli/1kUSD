# Deploy Placeholders (DEV45)
**Status:** No on-chain side-effects. For QA and wiring review only.

## Foundry
- Contract: `foundry/script/DeployPlaceholder.s.sol`
- Purpose: Encodes constructor args and emits them as events via `encode*()` calls.
- Usage idea: `cast` can be used off-chain to call `encode*` (no broadcast).

## Hardhat
- Script: `scripts/deploy.placeholder.ts`
- Purpose: Reads `ops/config/addresses.*.json` and `ops/config/params.staging.json`, prints ctor arg plan.
- Run: `node scripts/deploy.placeholder.ts` (after `npm i` for TS types if needed, or `ts-node`).

## Next Steps
- Introduce env-based resolution for admin addresses and chain selection.
- Add real deploy scripts guarded behind `DRY_RUN=true` and feature flags.
- Gate any broadcast with explicit `--network` and approval prompts.
