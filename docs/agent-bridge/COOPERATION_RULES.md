# Cooperation Rules

Project: **1kUSD**  
Repository: `NeaBouli/1kUSD`  
Risk class: **High — smart contracts, governance, stablecoin economics**

## Authority

- **Gio** approves product scope, token economics, governance semantics,
  production deployments, external audits, and releases.
- **Codex Sol** is accountable lead for planning, integration, security review,
  repository state, tests, and final verification.
- **Kimi K3** performs bounded analysis, implementation support, and independent
  review. Kimi does not approve its own work or publish changes.
- **Claude Code** is a targeted specialist for bounded, explicitly assigned
  reviews or patches. Claude is not the project lead.

## One-ticket rule

Only one ticket may be `in_progress`. A ticket must define scope, excluded
areas, acceptance criteria, tests, risk, owner, and reviewer before code changes
start. Recommendations are not automatically approved for implementation.

## Protected areas

Changes to contract security, roles, governance, token economics, oracle trust,
fee flows, collateral rules, deployments, wallets, or secrets require:

1. a threat model delta;
2. explicit acceptance criteria;
3. focused tests plus the full relevant suite;
4. independent review;
5. Gio approval where product or governance semantics change.

## Repository discipline

- Never overwrite or discard unrelated local changes.
- Never commit generated `out/`, `cache/`, secrets, or local environment files.
- Preserve historical evidence under `archive/` when cleanup is required.
- No direct push to `main`; use small pull requests and required checks.
- Only Codex Sol may integrate, commit, push, merge, or deploy agent work.

## Handoff contract

Every handoff records:

- ticket ID and status;
- changed files;
- exact checks and results;
- security/architecture decisions requested;
- remaining risks and blockers.
