# Release Process — Specification
**Scope:** Versioning, artifacts, tag discipline, deployment runbooks.  
**Status:** Spec (no code). **Language:** EN.

## Versioning
- SemVer tags: vMAJOR.MINOR.PATCH
- Contracts released post-audit & green CI

## Artifacts
- ABIs: contracts/abi/*.json
- Addresses: ops/config/addresses.<stage>.json
- Deploy logs: ops/deploy-logs/<stage>/YYYY-MM-DD_HHMM.json

## Flow
1) Branch: release/vX.Y.Z  
2) Freeze params for stage  
3) Staging fork dry-run (sim, invariants)  
4) Testnet deploy + publish ABIs/addresses  
5) Queue Timelock ops if needed  
6) Mainnet deploy + signed tag vX.Y.Z

## Rollback
- Revert on failed tx (no partials)
- Post-deploy issues: pause via Safety; roll-forward with fix

## Sign-offs
- Security lead + Protocol lead + Ops lead
