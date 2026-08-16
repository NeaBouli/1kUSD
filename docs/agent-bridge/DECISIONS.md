# Decision Register

| ID | Decision required | Options | Owner | Status |
|---|---|---|---|---|
| `DEC-001` | Product track | Kaspa primary; EVM executable reference only | Gio | Approved 2026-08-05 (`ADR-041`) |
| `DEC-002` | Post-sunset pause authority | Permanent ADMIN/DAO only; expired Guardian-only callers have no authority | Gio | Approved 2026-08-13 (`1K-P0-002`) |
| `DEC-003` | Guardian resume path | Direct ADMIN/DAO call to Safety; Guardian relay has no permanent role | Gio | Approved 2026-08-16 (`1K-P0-003`) |
| `DEC-004` | Fee destination | Reserve overcollateralization / treasury / split | Gio | Open |
| `DEC-005` | License | GPL-3.0 / AGPL-3.0 / documented per-file model | Gio + legal review | Open |
| `DEC-006` | Kaspa execution model | Singleton control/reserve L1 covenant family for the Testnet-10 PoC; production sharding deferred | Gio | Architecture approved 2026-08-16 (`ADR-042`); PoC implementation, deployment, wallet use, and real funds require a separate approved execution ticket |

Decision records must include rationale, security impact, compatibility impact,
date, and approving person. Open decisions must not be silently encoded in code.

## DEC-003 record

- **Decision/rationale:** Gio approved `1K-P0-003` on 2026-08-16. Resume is a
  direct permanent-authority call to `SafetyAutomata`; the Guardian contract is
  pause-only and receives only the temporary Guardian role.
- **Security impact:** removes the permanent all-module `DAO_ROLE` workaround
  from the Guardian relay, makes revocation explicit, and prevents
  self-escalation.
- **Compatibility impact:** legacy `selfRegister()` remains a non-mutating
  registration assertion and legacy `resumeOracle()` fails explicitly with
  `DirectResumeRequired`; no deployed Guardian is documented.
- **Approving person:** Gio / NeaBouli, repository owner.
