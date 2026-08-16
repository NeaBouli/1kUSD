# Open Questions

1. Which real collateral assets and decimal configurations are in scope?
2. Which oracle providers, quorum, heartbeat, deviation, and fallback policy are
   acceptable?
3. Who are the intended multisig signers and what threshold is required?
4. Should accumulated fees strengthen reserves, fund the treasury, or be split?
5. What legal entity, jurisdiction, reserve attestation, and redemption
   obligations apply before any public stablecoin launch?
6. What is the required testnet duration and value-at-risk ceiling?
7. Which bootstrap signer set and threshold are acceptable?
8. Which minimum governance delays apply to fees/limits, collateral/oracle
   policy, and governance self-administration?
9. Which future community-mandate model avoids unacceptable plutocracy, Sybil,
   delegation, bribery, and inactivity risk?
10. Is the EVM governance path permanently reference-only, or may it become a
    separately approved production candidate?
11. Which maintainer/release quorum and artifact-provenance policy define a
    community-maintained release without a single publisher?

## Resolved

- Product track: Kaspa Toccata is primary; EVM remains an executable reference
  without a current production commitment. See `ADR-041` / `DEC-001`.
- Kaspa execution model: Gio accepted the singleton control/reserve L1
  covenant-family direction for a Testnet-10 PoC on 2026-08-16. Production
  sharding is deferred to a later ADR. See `ADR-042` / `DEC-006`. This decision
  does not authorize PoC implementation or deployment.
