# Decision Register

| ID | Decision required | Options | Owner | Status |
|---|---|---|---|---|
| `DEC-001` | Product track | Kaspa primary; EVM executable reference only | Gio | Approved 2026-08-05 (`ADR-041`) |
| `DEC-002` | Post-sunset pause authority | DAO only / multisig + DAO / other | Gio | Open |
| `DEC-003` | Guardian resume path | Direct DAO call / role-bearing Guardian contract | Gio | Open |
| `DEC-004` | Fee destination | Reserve overcollateralization / treasury / split | Gio | Open |
| `DEC-005` | License | GPL-3.0 / AGPL-3.0 / documented per-file model | Gio + legal review | Open |
| `DEC-006` | Kaspa execution model | Singleton control/reserve L1 covenant family for the Testnet-10 PoC; production sharding deferred | Gio | Architecture approved 2026-08-16 (`ADR-042`); PoC implementation, deployment, wallet use, and real funds require a separate approved execution ticket |

Decision records must include rationale, security impact, compatibility impact,
date, and approving person. Open decisions must not be silently encoded in code.
