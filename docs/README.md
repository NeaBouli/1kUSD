<p align="center">
  <img src="assets/1kusd-banner.jpg" alt="1kUSD Kaspa Stablecoin" width="480">
</p>

# 1kUSD Documentation Index

This index organizes the documentation for the 1kUSD stablecoin protocol (v0.51.x).
For quick start and project overview, see the root [`README.md`](../README.md).

---

## Architecture & Design

- [Architecture overview](ARCHITECTURE.md) — core module map
- [Economic layer overview](architecture/economic_layer_overview.md)
- [PSM facade & vault wiring](architecture/psm_dev43-45.md)
- [PSM parameters & registry keys](architecture/psm_parameters.md)
- [PSM flows & invariants](architecture/psm_flows_invariants.md)
- [BuybackVault plan](architecture/buybackvault_plan.md)
- [BuybackVault execution](architecture/buybackvault_execution.md)
- [BuybackVault strategy RFC](architecture/buybackvault_strategy_rfc.md)

## Security & Audit Reports

- [Security audit (v0.51.x, Feb 2026)](reports/SECURITY_AUDIT_v051_2026-02.md)
- [Gas/DoS review](reports/GAS_DOS_REVIEW_v051.md) — 8 findings, all resolved
- [Deployment checklist (Phase 1-7)](reports/DEPLOYMENT_CHECKLIST_v051.md)
- [Threat model](THREAT_MODEL.md)
- [Emergency pause audit](audits/EMERGENCY_PAUSE_AUDIT_REPORT.md)

## Protocol Specifications

**PSM:**
- [PSM quote semantics](PSM_QUOTE_SEMANTICS.md) — decimals, fees, rounding
- [PSM quote math](PSM_QUOTE_MATH.md)
- [PSM revert reasons](PSM_REVERTS.md)
- [PSM limits & invariants](specs/PSM_LIMITS_AND_INVARIANTS.md)
- [Rounding rules](ROUNDING_RULES.md)

**Oracle:**
- [Oracle adapters](ORACLE_ADAPTERS.md)
- [Oracle aggregation guards](ORACLE_AGGREGATION_GUARDS.md)
- [ADR-040: Oracle watcher](adr/ADR-040-oracle-watcher.md)

**Safety & Guardian:**
- [Safety pause matrix](SAFETY_PAUSE_MATRIX.md)
- [Module IDs](MODULE_IDS.md)
- [Guardian sunset hooks](GUARDIAN_SUNSET_HOOKS.md)
- [Guardian sunset runbook](GUARDIAN_SUNSET_RUNBOOK.md)
- [Guardian safety rules](specs/GUARDIAN_SAFETY_RULES.md)

**Vault:**
- [Vault accounting](VAULT_ACCOUNTING.md)
- [Vault accounting edge cases](VAULT_ACCOUNTING_EDGE_CASES.md)
- [Fee accrual policy](FEE_ACCRUAL.md)

## Governance

- [Governance overview](GOVERNANCE.md)
- [Governance operations](GOVERNANCE_OPS.md)
- [Governance parameter writes](GOVERNANCE_PARAM_WRITES.md)
- [Parameter keys (canonical)](PARAM_KEYS_CANON.md)
- [Parameter registry spec](PARAMETER_REGISTRY.md)

## Testing

- [Test plan](testing/TESTPLAN.md)
- [Security analysis](testing/SECURITY_ANALYSIS.md)
- [Formal invariants map](testing/FORMAL_INVARIANTS_MAP.md)
- [Invariants harness notes](INVARIANTS_HARNESS_NOTES.md)
- [Error catalog](ERROR_CATALOG.md)

## Developer Guides

- [Developer onboarding](DEVELOPER_ONBOARDING.md)
- [Bootstrap quickstart](BOOTSTRAP_QUICKSTART.md)
- [Build tooling](BUILD_TOOLING.md)
- [SDK wiring guide](SDK_WIRING_GUIDE.md)

## Reports Archive

For the full list of status, governance, and sync reports:
- [Reports index](reports/REPORTS_INDEX.md)
- [Changelog](CHANGELOG.md)
