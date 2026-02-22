# 1kUSD Documentation

Welcome to the documentation for **1kUSD** — a security-first stablecoin protocol pegged 1:1 to USD.

Built on Ethereum today. Designed for native KASPA when the layer supports it.

---

## Getting Started

- [Architecture Overview](ARCHITECTURE.md) — core module map and system design
- [Bootstrap Quickstart](BOOTSTRAP_QUICKSTART.md) — build, test, deploy
- [Developer Onboarding](DEVELOPER_ONBOARDING.md) — setup and workflow guide
- [FAQ](FAQ.md)

## Protocol Specifications

- [PSM Quote Math](PSM_QUOTE_MATH.md) — decimals, fees, rounding
- [PSM Revert Reasons](PSM_REVERTS.md) — error codes and conditions
- [Vault Accounting](VAULT_ACCOUNTING.md) — collateral tracking and settlement
- [Parameter Registry](PARAMETER_REGISTRY.md) — on-chain parameter store
- [Rounding Rules](ROUNDING_RULES.md) — protocol-wide rounding policy

## Security & Safety

- [Safety Pause Matrix](SAFETY_PAUSE_MATRIX.md) — per-module pause controls
- [Threat Model](THREAT_MODEL.md) — attack classes and mitigations
- [Security Pre-Audit Readme](SECURITY_PREAUDIT_README.md) — security posture
- [Error Catalog](ERROR_CATALOG.md) — complete error code reference

## Audit Package

The protocol ships with a comprehensive audit documentation package:

- [Audit Scope](audit/AUDIT_SCOPE.md) — scope, file manifest, build instructions
- [Shipment Manifest](audit/SHIPMENT_MANIFEST.md) — SHA-256 checksums, build verification
- [Invariants](audit/INVARIANTS.md) — 35 protocol invariants with coverage matrix
- [Economic Risk Scenarios](audit/ECONOMIC_RISK_SCENARIOS.md) — 5 risk scenarios with mitigations
- [Known Limitations](audit/KNOWN_LIMITATIONS.md) — 12 accepted limitations

See the full [Audit Package](audit/AUDIT_SCOPE.md) section in the sidebar for all 11 documents.

## Governance

- [Governance Overview](GOVERNANCE.md) — parameter governance via DAO Timelock
- [Parameter Keys Catalog](PARAM_KEYS_CATALOG.md) — complete parameter reference
- [Guardian Sunset Runbook](GUARDIAN_SUNSET_RUNBOOK.md) — guardian phase-out process

## Status

- [Changelog](CHANGELOG.md)
- [Project Status](STATUS.md)

---

**Follow development:** [@Kaspa_USD on X](https://x.com/Kaspa_USD) | [GitHub](https://github.com/NeaBouli/1kUSD)
