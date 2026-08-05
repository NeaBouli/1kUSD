# Contributing to 1kUSD

Repository language is English. The project is a high-risk smart-contract and
stablecoin system, so changes are intentionally small and evidence-driven.

## Before starting

1. Read [PROJECT_STATE.md](docs/agent-bridge/PROJECT_STATE.md).
2. Select an approved GitHub issue from the
   [ticket list](docs/agent-bridge/TICKET_LIST.md).
3. Confirm scope, excluded files, dependencies, risk, owner, reviewer,
   acceptance criteria, and required tests.
4. For contracts, governance, oracle, collateral, fees, or deployments, include a
   threat-model and invariant delta before implementation.

## Pull requests

- One bounded concern per PR.
- Branch from current `main`; do not work directly on `main`.
- Do not mix dependency upgrades, workflow changes, formatting, and protocol logic.
- Never include secrets, local environments, generated `out/` or `cache/`, wallet
  files, broadcasts, or production configuration.
- Explain what changed, why, user/security impact, checks, remaining risk, and
  rollback/containment.

## Required verification

For Solidity changes, at minimum:

```bash
forge build
forge test -vv
forge test --match-contract Invariant -vv
forge lint
```

Run focused regression tests first, then the full relevant suite. New semantics
require tests that fail before the fix and pass after it. A placeholder or static
test-count badge is not verification.

For documentation changes:

```bash
mkdocs build --clean --strict
```

## Review and merge

- CI must pass and all review conversations must be resolved.
- Contract/security/economic changes require independent review.
- Authors do not self-approve delegated work.
- Only the accountable lead publishes or integrates agent-generated changes.
- Mainnet deployment and release require explicit Gio approval and all master-plan
  release gates.

## Licensing

License metadata is currently being reconciled. Preserve existing file SPDX
identifiers and do not mass-change license headers without an approved legal task.
