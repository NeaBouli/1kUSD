# Audit Follow-up — 2026-08-05

This document records the verified baseline that triggered the remediation
program. It is not an external audit certificate.

## Verification

- Foundry: 198 passed, 0 failed, 0 skipped across 35 suites.
- Ten tests are explicit placeholders.
- Coverage: 78.92% lines, 77.69% statements, 57.63% branches, 72.69% functions.
- Slither 0.11.5: the config is now valid and blocks on Medium findings. The
  current run analyzed 52 contracts and reported eight Medium results across
  divide-before-multiply, strict equality, locked Ether, and an uninitialized
  local; these findings remain open for ticketed triage.
- OpenZeppelin submodule commit is exact v5.4.0, not the documented v4.8.0.
- `audit-final-v0.51.5` resolves to commit `5906ba6`; freeze docs cite `fb3849b`.
- GitHub Pages reported built but returned HTTP 404 during the audit because
  uppercase `docs/INDEX.md` generated `/INDEX/` instead of a root page. The
  remediation branch renames it to `docs/index.md` and verifies `site/index.html`.

## Highest-priority findings

1. Default `SafetyAutomata` admin also holds Guardian role and cannot pause after
   the guardian sunset because role precedence checks Guardian first.
2. `Guardian.selfRegister()` calls an admin-only Safety function from a contract
   that does not yet hold the admin role; resume requires another role not granted
   by self-registration.
3. The canonical deploy script does not deploy/wire a complete production
   governance, oracle, Guardian, or fee-routing system.
4. Mock oracle, timelock stub, placeholder tests, and incomplete routing contradict
   the public production/audit-ready language.
5. Kaspa Toccata requires a UTXO/covenant-native design, not a Solidity port.
6. Slither's remaining Medium findings require focused false-positive analysis,
   fixes where applicable, tests, and independent review.

## Positive baseline

Core source is buildable, current `getPrice()` syntax is correct, production token
paths use SafeERC20, the project contains meaningful invariant/economic tests, and
many historical limitations are already documented.

All findings are tracked in the Bridge and GitHub issues. Contract findings remain
open until code, focused tests, full tests, and independent recheck are complete.
