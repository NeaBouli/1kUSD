# Invariants Mapping — Tests Matrix
**Status:** Spec (no code). **Language:** EN.

| Invariant | Summary | Test Type | Suite | Notes |
|---|---|---|---|---|
| I1 | Supply Bound | Property | psm_vault_invariants | Vault USD ≥ 1kUSD supply (oracle advisory) |
| I2 | PSM Conservation | Unit/Property | psm_accounting | Mint/Redeem deltas, fees consistent |
| I3 | No Free Mint | Integration | psm_mint_flow | Mint requires approved stable deposit |
| I4 | No Unauthorized Burn | Unit/Integration | token_authz | Burn only via authorized module |
| I5 | Caps Enforced | Unit/Integration | safety_caps | Deposit/systemDeposit ≤ cap |
| I6 | Rate Limits | Property | safety_rate_limit | Sliding window ≤ maxAmount |
| I7 | Pause Safety | Integration | safety_pause | State ops revert when paused |
| I8 | Oracle Liveness | Unit/Integration | oracle_guards | Stale > maxAgeSec blocks swaps |
| I9 | Deviation Guard | Unit/Integration | oracle_deviation | >maxDeviationBps blocks swaps |
| I10 | Atomic Snapshot | Integration | oracle_snapshot | Single coherent read per swap |
| I11–I13 | Event Consistency | Unit | events_consistency | Amount relations + FeeAccrued |
| I14–I15 | Reentrancy/Order | Unit | reentrancy | NonReentrant + CEI |
| I16 | Treasury Path Only | Integration | treasury_flow | GOV_SPEND via Timelock only |
| I17 | Param Governance Only | Integration | governance_params | Changes via Timelock/Safety |
