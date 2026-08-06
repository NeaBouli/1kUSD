# 1kUSD Project Context

## Read first

1. `docs/agent-bridge/COOPERATION_RULES.md`
2. `docs/agent-bridge/PROJECT_STATE.md`
3. `docs/agent-bridge/CODEX_FINDINGS.md`
4. the exact approved GitHub issue

## Current truth

- EVM research/testnet prototype; not mainnet-ready.
- Canonical build/test tool: Foundry.
- Solidity target: 0.8.30, Paris EVM.
- Canonical token: `contracts/core/OneKUSD.sol`.
- Canonical PSM: `contracts/core/PegStabilityModule.sol`.
- Tests: `foundry/test/`; deployment demo: `foundry/script/Deploy.s.sol`.
- 198 tests passed in the 2026-08-05 verification, but ten are placeholders.
- Mock oracle, timelock stub, incomplete fee routing, and open role findings block
  production.
- Kaspa Toccata is UTXO/covenant-native; do not port EVM contracts line by line.

## Agent role

Claude Code is a targeted specialist, not the lead. Work only on a bounded,
explicitly assigned ticket. Do not start agents, widen scope, commit, push, merge,
deploy, access secrets, or approve architecture/security/economic decisions.

Document results in `docs/agent-bridge/CC_RESPONSE.md` for Codex Sol review.

## Protected areas

Do not change governance, roles, token economics, oracle trust, collateral policy,
fee policy, deployment, wallets, or secrets without the issue's explicit approval,
threat-model delta, tests, and review requirements.
