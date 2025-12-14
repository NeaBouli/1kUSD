#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md"

python3 - <<'PY'
from pathlib import Path
import textwrap

path = Path("docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md")

content = textwrap.dedent("""
    # DEV-11 Phase B – Telemetry Test Plan (OracleRequired, r1)

    This document defines the **test strategy for Telemetry Phase B**
    around the **OracleRequired Operations Bundle** for the Economic
    Layer v0.51.x.

    It is a *planning document* for future tests – it does **not**
    introduce any Solidity or CI changes by itself.

    ## 1. Goals

    The primary goals of this test plan are:

    - Ensure that all **OracleRequired-related states** are
      **observable** through logs, events and revert reasons.
    - Provide a clear mapping from **on-chain behavior** to what an
      **indexer / monitoring stack** must validate.
    - Support future runbooks and dashboards with **deterministic
      signals**, especially for:
      - `PSM_ORACLE_MISSING`
      - `BUYBACK_ORACLE_REQUIRED`
      - `BUYBACK_ORACLE_UNHEALTHY`
    - Keep the boundary between **Economic Layer code** and
      **Telemetry/Indexer** clear:
      - Solidity tests focus on events / errors.
      - Indexer tests focus on decoding and classification.

    Non-goal: This document does **not** define any UI or product
    decisions – it is strictly about testable technical signals.

    ## 2. Scope

    In scope for DEV-11 Phase B tests:

    - Economic Layer v0.51.x components which participate in the
      OracleRequired bundle:
      - PegStabilityModule (PSM)
      - BuybackVault
      - Oracle watcher / health modules
      - Guardian propagation / pause flows (where relevant)
    - On-chain signals:
      - Events already emitted today (no new events are required for
        Phase B).
      - Revert reasons and error selectors used by PSM and
        BuybackVault.
    - Off-chain signals (for indexers / monitoring):
      - Decoding of events and revert reasons.
      - Classification of **healthy vs. illegal** states.
      - Alert triggers for OracleRequired violations.

    Out of scope for this test plan:

    - New strategy logic in BuybackVault beyond Phase A.
    - A03 rolling-window boundary tests (explicitly parked by the
      architect for a later hardening wave).
    - Any direct integration with specific monitoring tools
      (Grafana, Prometheus, etc.) – these are consumers of the
      signals defined here.

    ## 3. Test Matrix (high level)

    | Layer            | Focus                                  | Artifacts                          |
    |------------------|----------------------------------------|------------------------------------|
    | Solidity (Foundry) | Events & revert reasons               | `*.t.sol` regression suites        |
    | Indexer logic    | Decoding + classification              | indexer tests / scripts            |
    | Alerts           | Thresholds & triggers                  | monitoring rules (out of scope)    |
    | Runbooks         | Operational response to alerts         | ops docs (out of scope)            |

    This plan primarily concerns the **Solidity** and **Indexer**
    layers. Alerts and runbooks are referenced only as consumers.

    ## 4. Solidity / Foundry test strategy (Phase B)

    Future Solidity-level tests for Telemetry Phase B should:

    1. **PSM / OracleRequired:**
       - Verify that operations which depend on an oracle price
         revert with `PSM_ORACLE_MISSING` when:
         - No oracle is configured.
         - The oracle is explicitly disabled by governance.
       - Ensure that these reverts are already covered in existing
         regression tests, and extend them only when necessary
         to make the revert reasons **deterministic**.

    2. **BuybackVault / OracleGate:**
       - Ensure `BUYBACK_ORACLE_REQUIRED` is emitted/used when:
         - Strict mode is enabled.
         - No health module is configured.
       - Ensure `BUYBACK_ORACLE_UNHEALTHY` (or equivalent gate
         reason) is used when the health module marks the oracle
         as unhealthy.
       - Verify that the **observable behavior** (revert reason)
         is stable and can be relied upon by indexers.

    3. **Guardian / pause flows:**
       - Confirm that guardian pause / unpause flows do not
         silently bypass OracleRequired invariants.
       - Where appropriate, check that the same reason codes are
         used regardless of whether the operation is invoked in a
         "happy path" or after a guardian intervention.

    4. **Negative / illegal state scenarios:**
       - Tests should explicitly exercise **illegal states**
         (as defined in:
         `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`),
         and confirm that:
         - The operation does **not** succeed.
         - A clear revert reason is observable.

    Implementation notes (for future DEV-11 Solidity work):

    - Prefer **existing test suites** (`OracleRegression_*`,
      `PSMRegression_*`, `BuybackVault.t.sol`) as hosts for
      additional assertions, instead of introducing new ad-hoc
      tests.
    - Keep new asserts **thin** and focused on observability:
      - do not duplicate business logic tests,
      - only assert that the **expected signal** is produced.

    ## 5. Indexer / Telemetry test strategy (Phase B)

    The indexer side is responsible for turning raw on-chain
    signals into **structured records** which monitoring and
    dashboards can consume.

    For Phase B, the indexer tests should cover:

    1. **Event decoding:**
       - Ensure that all relevant Economic Layer events used in
         OracleRequired flows can be decoded from logs:
         - PSM swap / mint / redeem events.
         - BuybackVault operations (funding, buyback, withdrawals).
         - Guardian / pause-related events (where applicable).

    2. **Revert reason decoding:**
       - Ensure that revert reasons for:
         - `PSM_ORACLE_MISSING`
         - `BUYBACK_ORACLE_REQUIRED`
         - `BUYBACK_ORACLE_UNHEALTHY`
         can be reliably decoded from transaction receipts and/or
         simulation results.
       - Classify these reasons into **severity categories**:
         - "oracle misconfiguration" vs. "oracle unhealthy" etc.

    3. **Derived status flags:**
       - From decoded events and revert reasons, compute simple
         boolean flags which can be exposed to monitoring:
         - `psm_oracle_required_violation`
         - `buyback_oracle_required_violation`
         - `buyback_oracle_unhealthy_violation`
       - Tests should verify that:
         - for a given synthetic input (set of logs / reverts),
           the flags are set correctly.
         - no flag is raised in happy-path scenarios.

    4. **Minimal data model checks:**
       - If the indexer stores these flags in a database (e.g.
         Postgres), tests should verify:
         - correct schema / field names,
         - idempotent writes for repeated events,
         - basic retention / cleanup behavior (if applicable).

    Implementation notes (for future DEV-11 indexer work):

    - Keep indexer tests **deterministic** and independent of any
      external price feeds.
    - Use **recorded test vectors** from a local devnet or a
      fork environment where possible.

    ## 6. Operational checks (conceptual)

    While not implemented as automated tests in this repo, this
    test plan assumes that operators will eventually have:

    - A **pre-release checklist** that includes running:
      - `./scripts/check_release_status.sh`
      - and verifying that both the status reports and the
        OracleRequired docs gate pass (exit code 0).
    - At least one **dashboard** that surfaces:
      - current Oracle health status,
      - recent OracleRequired violations (if any).

    The OracleRequired Operations Bundle report should remain the
    **single point of truth** for:
    - which states are illegal, and
    - which reason codes signal them.

    ## 7. Risks and open points

    - Future Economic Layer changes might introduce new Oracle-
      related reason codes; DEV-11 will need to keep this test
      plan in sync with the Architect bulletins.
    - Indexer implementations may vary; this plan describes the
      **expected behavior**, not a specific technology.
    - A03 rolling-window boundary tests are intentionally parked
      and should be handled in a later **test hardening wave**
      (DEV-11 Phase C or similar).

    ## 8. Summary

    DEV-11 Phase B Telemetry tests will ensure that:

    - OracleRequired invariants are not only enforced on-chain,
      but also **visible and interpretable** off-chain.
    - Reason codes and events are treated as **first-class
      observability signals**.
    - Future monitoring and governance tooling can rely on a
      stable, well-documented set of signals for incident
      response and audits.
    """)

path.write_text(content.lstrip("\n"), encoding="utf-8")
print("DEV11 PhaseB Telemetry TestPlan r1 written.")
PY

echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add PhaseB telemetry test plan r1" >> logs/project.log
echo "== DEV-11 PhaseB step04: Telemetry TestPlan r1 written =="
