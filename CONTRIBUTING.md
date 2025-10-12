# Contributing to 1kUSD

**Repository language: English.**  
Whitepaper is available in German and English (see `docs/whitepaper/`).

## Roles & workflow
- **Main Architect:** owns architecture & task assignment (issues/prompts).  
- **Developers:** deliver **EOF-closed files** (here-doc style) and minimal shell snippets.  
- **Middleman:** runs copy-paste commands locally (no secrets shared).

## Branching & commits
- Default branch: `main`.  
- Prefer small, reviewable PRs.  
- Commit messages: `type(scope): short summary`  
  - Examples: `docs(whitepaper): add EN version`, `ci: enable tests`, `chore: bump deps`

## Pull requests
1. Reference the task/prompt in the PR description.  
2. Include what changed, why, and how it was tested.  
3. Ensure CI passes; add/adjust tests if needed.  
4. Do **not** include secrets; use placeholders and .env.example if relevant.

## EOF-based deliverables (required)
- All artifacts must be provided as **here-doc** payloads ending with `EOF`.  
- Shell snippets must be **idempotent** (safe to re-run).  
- Include any new or updated file paths explicitly.

## Coding standards (to be detailed later)
- Solidity/TS formatting via project tooling (to be defined).  
- Prefer clear interfaces first (IDL/ABI/API specs), then implementation.

## Tests & quality gates
- Unit + integration tests required for core logic (VM/PSM/Vault/Oracle).  
- Fuzz/property tests for parsers/financial invariants.  
- Lint + static analysis (Slither/Mythril/ESLint) in CI.  
- No merge to `main` with failing CI.

## Security
- Follow `SECURITY.md`. Use GitHub Security Advisories for sensitive reports.  
- Ownerless/Timelock patterns; no EOAs controlling funds.  
- Never commit private keys, tokens, or credentials.  
- SBOM & signed releases prior to mainnet.

## Documentation
- Update `docs/CHANGELOG.md` for user-facing or protocol-level changes.  
- Keep `interfaces/` and `docs/API_SPECS.md` aligned with contract/SDK changes.

## How to run tasks locally (middleman)
- Copy-paste the provided here-doc blocks into the terminal at repo root.  
- Verify with `git status`, then commit/push as instructed in the snippet.

Thanks for contributing to 1kUSD!
