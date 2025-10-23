# Build/Tooling — Skeleton

**Status:** No tests yet. Contracts compile-able via Foundry *oder* Hardhat.

## Foundry
- Config: `foundry/foundry.toml`
- Compile: `forge build` (requires Foundry installed)
- Format: `forge fmt`

## Hardhat (TypeScript)
- Config: `hardhat.config.ts`
- Install dev deps locally (optional): `npm i`
- Compile: `npm run hh:compile`
- Local node: `npm run hh:node`

## Notes
- Solidity version pinned to **0.8.24** to match interface stubs.
- No deployments/scripts except placeholder `foundry/script/Deploy.s.sol`.
- CI integration will stay **placeholder** until code exists.

## Build/CI Sanity
- GitHub Actions: `build.yml` compiles contracts via Hardhat with Node 20.
- Foundry `fmt` is currently a placeholder workflow; can be upgraded to install Foundry later.
