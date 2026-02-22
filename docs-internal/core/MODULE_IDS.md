# Canonical Module IDs (bytes32)
**Status:** Docs. **Language:** EN.

Modules must use the same IDs across on-chain code, SDKs, and ops tooling.

| Name | bytes32 (keccak256 of string) | String seed |
|---|---|---|
| PSM | `keccak256("PSM")` | `"PSM"` |
| VAULT | `keccak256("VAULT")` | `"VAULT"` |
| ORACLE | `keccak256("ORACLE")` | `"ORACLE"` |
| TOKEN | `keccak256("TOKEN")` | `"TOKEN"` |
| REGISTRY | `keccak256("REGISTRY")` | `"REGISTRY"` |
| GOV | `keccak256("GOV")` | `"GOV"` |

> Tip: Clients should **compute** the hash rather than hardcoding hex literals to avoid chain-specific mismatches.
