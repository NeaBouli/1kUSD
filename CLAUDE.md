# Project Handover – 1kUSD

## Current Status

**Version:** v0.51.5 (Sprint 3 contracts frozen, Sprint 4 repo overhaul complete)
**Branch:** `main` at commit `e2187cb` (pushed to `origin/main`)
**Tests:** 233 passing across 36 suites, 0 failures
**Compiler:** Solidity 0.8.30, Foundry (Paris EVM, optimizer 200 runs)

The protocol smart contracts are audit-frozen at tag `audit-final-v0.51.5`. No contract code changes are in scope for the current phase.

A major repository overhaul was just completed (Sprint 4) that separated documentation into three tiers:
- **`docs/`** — Marketing-only GitHub Pages site (MkDocs Material theme). 8 user-facing pages + whitepaper.
- **`docs-internal/`** — All technical documentation (architecture, specs, governance, dev guides, reports). Not served publicly.
- **`audit/`** — 11 frozen audit documents. Standalone, not part of docs/ or docs-internal/.
- **GitHub Wiki** — 38 pages prepared but NOT YET PUSHED. Backup at `~/Desktop/1kUSD-wiki-backup/`.

### What was pushed in Sprint 4 (all on `main`):
| Commit | Description |
|--------|-------------|
| `e3049c4` | Fix all RED CI workflows, consolidate duplicates |
| `26f7847` | Professional README with KASPA vision + logo |
| `d22e95b` | Clean mkdocs nav, add audit package section, rewrite landing page |
| `dafa275` | Fix docs deployment workflows (fetch-depth: 0) |
| `1672053` | Separate docs/ for marketing, move ~150 technical files to docs-internal/ |
| `5144688` | Rewrite GitHub Pages as 8-page marketing site |
| `e2187cb` | Fix README cross-links for new structure |

### Blocked item: GitHub Wiki deployment
38 wiki pages (6,442 lines) are prepared and backed up at `~/Desktop/1kUSD-wiki-backup/`. The wiki git repo does not yet exist because GitHub requires the first wiki page to be created manually via the web UI. Steps to deploy:
1. Navigate to `https://github.com/NeaBouli/1kUSD/wiki` in a browser
2. Click "Create the first page" and save with any content
3. Then run:
```bash
cd ~/Desktop/1kUSD-wiki-backup
git remote add origin https://github.com/NeaBouli/1kUSD.wiki.git
git push -u origin master --force
```

## Architecture Decisions

### Smart Contract Architecture
1kUSD is a collateralized stablecoin pegged 1:1 to USD. No CDP/debt model — users deposit collateral and receive 1kUSD at oracle price via the Peg Stability Module (PSM).

**Core modules and their contracts:**

| Module | Contract(s) | Location |
|--------|------------|----------|
| Token | `OneKUSD.sol` | `contracts/core/` |
| PSM | `PegStabilityModule.sol`, `PSM.sol`, `PSMSwapCore.sol`, `PSMLimits.sol` | `contracts/core/`, `contracts/psm/` |
| Vault | `CollateralVault.sol`, `TreasuryVault.sol` | `contracts/core/`, `contracts/vault/` |
| Oracle | `OracleAggregator.sol`, `OracleAdapter.sol`, `OracleWatcher.sol` | `contracts/core/`, `contracts/oracle/` |
| Safety | `SafetyAutomata.sol`, `SafetyNet.sol`, `Guardian.sol`, `GuardianMonitor.sol` | `contracts/core/`, `contracts/security/` |
| Buyback | `BuybackVault.sol`, `IBuybackStrategy.sol` | `contracts/core/`, `contracts/strategy/` |
| Governance | `ParameterRegistry.sol`, `DAO_Timelock.sol` | `contracts/core/` |
| Fees | `FeeRouter.sol`, `FeeRouterV2.sol` | `contracts/core/`, `contracts/router/` |

**Deployment order:** Registry → Safety → Vaults → Limits → Oracle → PSM → FeeRouter → Buyback

**Key design decisions:**
- Oracles are MANDATORY for PSM and BuybackVault — no oracle-free path exists.
- Guardian is temporary (pause-only); sunset mechanism removes guardian power after a timestamp.
- Only DAO/Timelock can unpause modules (guardian can only pause).
- Single-asset buyback only in v0.51.x (multi-asset is v0.52+).
- No proxy pattern in v0.51.x.
- Revert-first error handling — every error has a catalog entry.

### Documentation Architecture
- **`docs/`** = GitHub Pages marketing site ONLY. Served via MkDocs Material at `neabouli.github.io/1kUSD/`. Non-technical, user-facing, KASPA-vision focused. Contains 8 marketing pages + 2 whitepaper translations.
- **`docs-internal/`** = Technical documentation. Not publicly served. Contains ~150 files across 21 subdirectories (architecture, specs, governance, dev guides, reports, logs, etc.).
- **`audit/`** = 11 audit documents, frozen at tag `audit-final-v0.51.5`. Referenced by README but not part of either docs system.
- **GitHub Wiki** = Public-facing technical docs. 38 pages: 11 audit copies (with freeze headers), 18 full-copy technical pages, 6 summary+link pages, plus Home/Sidebar/Footer. NOT YET LIVE.

**Critical rule:** NEVER put technical docs back into `docs/`. That directory is marketing only.

### CI/CD
Active workflows in `.github/workflows/`:
- `foundry.yml` — Forge build + test
- `ci.yml` — Solidity CI
- `docs.yml` — MkDocs deploy to GitHub Pages
- `docs-build.yml` — MkDocs build check
- `docs-check.yml` — Docs validation
- `docs-linkcheck.yml` — Link checking
- `buybackvault-strategy-guard.yml`, `deploy-skeleton.yml`, `docker-baseline-build.yml`, `release-status.yml` — Auxiliary

Disabled: `_disabled_release.yml.disabled`, `_disabled_security-gate.yml.disabled`, `docs.yml.disabled`

All workflows use `fetch-depth: 0` for git-revision-date-localized-plugin compatibility.

## Project Structure

```
1kUSD/
├── contracts/
│   ├── core/              15 Solidity files (OneKUSD, PSM, Vault, Oracle, Safety, Buyback, etc.)
│   ├── interfaces/        12 interface files (I1kUSD, IPSM, IVault, IOracleAggregator, etc.)
│   ├── mocks/             Mock contracts for testing
│   ├── oracle/            OracleAdapter.sol, OracleWatcher.sol
│   ├── psm/               PSM.sol, PSMLimits.sol, PSMSwapCore.sol
│   ├── router/            FeeRouterV2.sol, IFeeRouterV2.sol
│   ├── security/          Guardian.sol
│   ├── specs/             Contract specifications
│   ├── strategy/          IBuybackStrategy.sol
│   └── vault/             TreasuryVault.sol
├── foundry/
│   ├── test/              36 test suites (unit, config, regression, invariant, econ sim)
│   └── script/            Deploy.s.sol, DeployVerify.s.sol, Monitor.s.sol
├── audit/                 11 frozen audit docs (AUDIT_SCOPE, THREAT_MODEL, INVARIANTS, etc.)
├── docs/                  Marketing site only (INDEX.md, 7 marketing pages, whitepaper/, assets/)
├── docs-internal/         ~150 technical docs across 21 subdirectories
│   ├── core/              50 root-level technical docs (ARCHITECTURE, GOVERNANCE, ERROR_CATALOG, etc.)
│   ├── architecture/      Architecture deep-dives
│   ├── specs/             14 specification files
│   ├── security/          Audit plan, bug bounty
│   ├── risk/              Collateral risk, depeg runbook, proof of reserves
│   ├── testing/           Testing guides
│   ├── governance/        Governance playbooks
│   ├── integrations/      Integration guides
│   ├── indexer/           Indexer docs
│   ├── dev/               Internal dev docs
│   ├── logs/              Session logs
│   ├── reports/           Dev reports (GAS_DOS_REVIEW, DEPLOYMENT_CHECKLIST, etc.)
│   └── (7 more subdirs)  planning, notes, misc, releases, dapp, converter, economics, adr, audits
├── lib/                   forge-std, openzeppelin-contracts
├── .github/workflows/     CI pipelines
├── mkdocs.yml             Marketing site config (9-page nav)
├── foundry.toml           Forge configuration
├── README.md              Professional README with dual links (Website + Wiki)
└── CLAUDE.md              This file
```

### Key configuration files:
- **`foundry.toml`**: solc 0.8.30, Paris EVM, optimizer 200 runs, invariant: 256 runs x 64 depth
- **`mkdocs.yml`**: Material theme, teal/lime palette, 9-page marketing nav
- **`.gitignore`**: Excludes node_modules, out/, cache/, broadcast/, site/, .env

## Open TODOs

### Immediate (blocked on manual action)
1. **Push GitHub Wiki** — Wiki must be initialized via web UI first, then push 38 pages from `~/Desktop/1kUSD-wiki-backup/`. See steps in "Current Status" above.
2. **Verify GitHub Pages deployment** — After push, confirm marketing site renders at `neabouli.github.io/1kUSD/`.
3. **Verify Wiki navigation** — After wiki push, confirm `_Sidebar.md` links all resolve correctly.

### Short-term cleanup
4. **Update README test badge** — Badge says "198/198 passing" but actual count is now 233/233. Update line 16 of `README.md`.
5. **Clean leftover directories in `docs/`** — `docs/logs/` (empty), `docs/redirects/` (contains index.html), `docs/scripts/` (contains scan_docs.sh), `docs/governance/proposals/` (contains a template JSON). These are remnants from the migration and should either be moved to `docs-internal/` or deleted.
6. **Remove stale image files from repo root** — `1kUSD.png` and `1kusd_400x400.jpg` are untracked in the repo root. The actual logo used is at `docs/assets/1kUSD.png`. Decide whether to delete or `.gitignore` these root copies.
7. **Remove `.bak` test files** — `foundry/test/` contains 3 `.bak` files (Guardian_OraclePropagation, OracleAggregator, Guardian_PSMUnpause). These should be deleted or moved.

### Future phases (v0.52+)
8. **Functional DAO Timelock** — Currently a placeholder/stub.
9. **Chainlink oracle integration** — Replace mock oracle adapters.
10. **FeeRouter v2 activation** — `FeeRouterV2.sol` exists but is not wired into PSM.
11. **Multisig deployment** — No multisig in v0.51.x.
12. **KASPA evaluation** — Research phase for native KASPA smart contract layer.

## Known Issues

1. **Wiki not live** — The 38 prepared wiki pages at `~/Desktop/1kUSD-wiki-backup/` need manual GitHub wiki initialization before they can be pushed. The `/tmp/1kUSD-wiki/` original is ephemeral and may be lost on reboot.
2. **Stale test count in badges** — README badge and several doc references say "198 tests" but actual count is 233 after recent additions. The audit docs intentionally reference 198 (frozen count at audit time).
3. **Leftover dirs in `docs/`** — `logs/`, `redirects/`, `scripts/`, `governance/proposals/` survived the migration. They are harmless but should be cleaned.
4. **MkDocs 2.0 compatibility warning** — `mkdocs build` shows a warning about Material theme incompatibility with MkDocs 2.0. Currently harmless (still on MkDocs 1.x). Will need theme update when MkDocs 2.0 is adopted.
5. **Branch protection bypass** — Pushes to `main` currently bypass the "Changes must be made through a pull request" branch protection rule. This is intentional for now (admin pushes) but should be tightened before mainnet.
6. **Two TreasuryVault.sol files** — One at `contracts/core/TreasuryVault.sol` and one at `contracts/vault/TreasuryVault.sol`. Potential duplication to investigate.
7. **`out/` and `cache/` in git status** — Foundry build artifacts show as modified in `git status` but are gitignored. This is normal Foundry behavior.

## Explicit Non-Goals

These are explicitly OUT OF SCOPE for v0.51.x. Do not implement:
- **Multi-feed oracle consensus** — v0.52+ only.
- **Staleness/deviation as mandatory enforcement** — v0.52+ only.
- **Bridge anchor / Kasplex integration** — v0.6x+ research phase.
- **AutoConverter / best-execution router** — Future.
- **Full governance token + on-chain voting** — v0.52+ only.
- **Multi-asset buyback** — v0.52+ only.
- **Proxy/upgradeable patterns** — No proxies in v0.51.x.
- **New features or policy gates** — v0.51.x is bugfix, security, tests, docs, wiring ONLY.
- **Putting technical docs back into `docs/`** — `docs/` is marketing only. Technical content belongs in `docs-internal/` or the Wiki.
- **Changing audit-frozen contracts** — Contracts at tag `audit-final-v0.51.5` must not be modified.

## Code Conventions

### Solidity
- Solidity `^0.8.19` to `0.8.30` (production code targets 0.8.30).
- Foundry as build/test framework (`forge build`, `forge test`).
- Paris EVM target, optimizer enabled (200 runs).
- Remappings: `forge-std/=lib/forge-std/src/`, `@openzeppelin/=lib/openzeppelin-contracts/`.
- Revert-first error handling — custom errors, no `require` strings.
- Every error code has an entry in `docs-internal/core/ERROR_CATALOG.md`.
- Line length: 100 characters (enforced by `forge fmt`).

### Mandatory dev rules (Rules A-E)
- **Rule A:** No silent requirements. Every new condition needs a misconfig test + happy-path test + doc update.
- **Rule B:** Oracles are mandatory for PSM and BuybackVault. No oracle-free paths.
- **Rule C:** Every error code needs an ERROR_CATALOG entry + telemetry schema + metric/alert.
- **Rule D:** Separate commits: code, tests, docs. NO mega-commits.
- **Rule E:** NO hidden unicode. Plain ASCII/UTF-8 only. Verify before commit.

### Commit conventions
- Conventional commits: `feat:`, `fix:`, `test:`, `docs:`, `chore:`, `ci:`.
- One PR per topic with clear scope.
- Change proposals must include: intent, scope check (v0.51.x vs v0.52+), wiring impact, tests, risk assessment.

### Testing
- 233 tests across 36 suites.
- Categories: unit (52), config/auth (79), regression (19), integration (7), smoke (9), invariant/fuzz (18, 256 runs x 64 depth), economic simulation (10), misc (4).
- Tests live in `foundry/test/`. Naming: `<Module>.t.sol`, `<Module>_<Aspect>.t.sol`.
- Invariant tests use `Invariant` suffix. Economic simulations use `EconSim` suffix.

### Documentation
- Marketing pages in `docs/`: short, non-technical, KASPA-vision, @Kaspa_USD prominent.
- Technical docs in `docs-internal/`: detailed, developer-oriented, includes specs/architecture/governance.
- Wiki pages: `> Source: [path](GitHub URL)` header on full-copy pages linking back to repo.
- MkDocs config at repo root `mkdocs.yml`. Build with `mkdocs build --clean --strict`.

## Next Immediate Step

**Push the GitHub Wiki.** This is the single remaining deliverable from the docs/wiki separation work:

1. The user must create the first wiki page at `https://github.com/NeaBouli/1kUSD/wiki` via the web browser (GitHub API cannot initialize a wiki).
2. After initialization, push the 38 prepared pages:
```bash
cd ~/Desktop/1kUSD-wiki-backup
git remote add origin https://github.com/NeaBouli/1kUSD.wiki.git
git push -u origin master --force
```
3. Verify the wiki renders correctly, especially `_Sidebar.md` navigation.
4. Then clean up: update the README test badge from 198 to 233, remove leftover `docs/` subdirectories (`logs/`, `redirects/`, `scripts/`, `governance/`), and delete root-level stale image files.
