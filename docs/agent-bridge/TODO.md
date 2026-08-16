# Current TODO

## Active

- [x] Create approved `1K-P1-016` / Issue #127 and record its decision-only scope.
- [x] Draft ADR-043, the governance/control threat model, staged transition
  plan, authority matrix, and non-evasion boundary.
- [x] Obtain Kimi K3's independent architecture analysis.
- [x] Attempt targeted Claude Code security/control review and record its
  authentication-based unavailability without claiming review credit.
- [x] Obtain Kimi K3 final `APPROVE` on the complete diff and incorporate all
  Low/Info observations.
- [x] Pass strict docs, watchdog, internal/external link, and diff validation.
- [ ] Publish the decision-ready proposal through a normal pull request.
- [ ] Obtain Gio's explicit ADR-043 accept/reject decision; do not infer it from
  approval to draft the ADR.

## Next — requires separate Gio approval after target stop

- [ ] Create the value-capped Testnet-10 PoC execution ticket only under a
  separate Gio approval; ADR-042 is accepted, but execution is not authorized.
- [ ] After ADR-043 is resolved, respecify #107 and request separate execution
  approval; do not start implementation automatically.

## Not authorized in the current task

- Contract/Silverscript implementation, role transfer, multisig/DAO setup,
  voting-token design, parameter writes, or unrelated governance changes.
- PoC implementation or oracle, fee, collateral, or token-economics changes.
- Mainnet/testnet deployment, wallet actions, release, or tag rewriting.
