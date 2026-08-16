# Current TODO

## Active

- [x] Implement the approved `1K-P0-003` Guardian registration, revocation, resume,
  and sunset lifecycle under the approved Issue #103 scope.
- [x] Record the threat-model delta and explicit role truth table.
- [x] Add focused authorization, boundary, registration, revocation, and
  mixed-role tests; run the full Foundry suite and Slither.
- [x] Obtain Kimi K3 `APPROVE`; attempt the targeted Claude Code review and
  record its OAuth-based unavailability without claiming review credit.
- [x] Publish through normal PR #124 and pass Forge Build, Forge Test,
  docs-check, and configured CodeRabbit status checks.
- [ ] Obtain the required independent GitHub approval and close #103 only after
  normal merge; do not bypass the active review gate.

## Next — requires separate Gio approval after target stop

- [ ] Create the value-capped Testnet-10 PoC execution ticket only after ADR-042
  is accepted.
- [ ] Select `1K-P0-004` or another queued ticket; do not start automatically.

## Not authorized in the current task

- PoC implementation or unrelated governance, oracle, fee, collateral, or
  token-economics changes.
- Mainnet/testnet deployment, wallet actions, release, or tag rewriting.
