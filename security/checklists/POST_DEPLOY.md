
Security Checklist — Post-Deploy (v1)

On-chain State Verification

 Addresses match emitted template

 Roles/permissions match spec (token, PSM, Vault, Safety, DAO)

 Event smoke-test executed (small mint/redeem on test env if allowed)

Indexing & Telemetry

 Indexer caught up; finality watermark correct

 PoR rollup validates (scripts/por-rollup-validate.mjs)

 Health endpoint status "ok"; components green

Parameters Snapshot

 params.sample.json generated from chain + validated

 Collateral registry synced with decimals/metadata schema

DEX/Oracle Sanity

 dex-price-sanity report passes threshold

 Oracle adapters catalog validated; staleness alarms active

Documentation & Comms

 CHANGELOG release section updated

 Incident contacts confirmed; status page link posted

Monitoring Baselines

 Alerts: pause, oracle stale, cap/limit hits, large transfers

 Fee accrual deltas tracked and reconciled daily
