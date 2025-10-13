# Release Candidate (v0) — Criteria
**Status:** Info (no code). **Language:** EN.

## RC Gates
- **Specs Complete:** all core specs present (Token, PSM, Vault, Oracle, Safety, DAO, Treasury, Registry, Rate-Limits).
- **Tests Spec’d:** DEV13 test plan + invariants map + security analysis committed.
- **Security:** DEV18 threat model + risk register; no Critical/High open items.
- **CI:** green CI skeleton with reports schema (lint/unit/invariants/static).
- **Docs:** README, ARCHITECTURE, API/Interfaces, Ops specs (DEPLOYMENT, RELEASE, SECRETS, EMERGENCY).
- **Telemetry:** metrics/alerts/health specs (DEV19).
- **Integrations:** wallets/bridges/partner APIs specs (DEV20).
- **Legal (info):** stance, jurisdictions checklist, disclosures (DEV23).

## RC Artifacts
- Version placeholder: `v0.0.0-rc.1` (tag once code exists).
- Addresses templates: `ops/config/addresses.*.json` present.
- CHANGELOG entry drafted for RC.

## Exit to GA
- After audit + green CI with code, bump to `v0.0.0`.
