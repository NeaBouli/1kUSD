# Playbook — Release Rehearsal (Staging/Mainnet-Fork)
**Scope:** Dry-run of a full release using staging (mainnet fork) before testnet/mainnet.  
**Status:** Spec (no code). **Language:** EN.

## Preflight
- CI green; CHANGELOG drafted; version `vX.Y.Z` reserved
- Security: no Critical/High open (see SECURITY_ANALYSIS.md)
- Param freeze: proposed set captured in change set

## Steps
1) **Fork Prep**: spin mainnet fork, seed PoR balances for Vault
2) **Deploy**: run scripted deploy; capture addresses → `ops/config/addresses.staging.json`
3) **Migrate**: wire Safety/Registry params per change set
4) **Smoke**: PSM mint/redeem; pause/resume; oracle toggles; rate-limit window rollover
5) **Invariants**: run reduced invariant suite (≥ 5k steps)
6) **Telemetry**: verify metrics export and `/health`
7) **Artifacts**: ABI bundle + deploy logs → `ops/deploy-logs/staging/`
8) **Sign-off**: Security + Protocol + Ops

## Exit Criteria
- All smoke checks pass; invariants clean; telemetry healthy
- Addresses + artifacts committed; tag candidate annotated

## Rollback (Rehearsal)
- Exercise pause; revert params; re-run smoke to confirm recovery
