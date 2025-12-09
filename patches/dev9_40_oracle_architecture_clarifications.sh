#!/bin/bash
set -e

echo "== DEV-9 40: Oracle & Safety architecture clarifications (docs-only) =="

# 1) Economic layer overview – clarify oracle dependency (no 'oracle-free' mode)
ECO_FILE="docs/architecture/economic_layer_overview.md"
if [ -f "$ECO_FILE" ]; then
  if ! grep -q "Oracle dependencies – architecture clarification" "$ECO_FILE"; then
    cat <<'EOD' >> "$ECO_FILE"

## Oracle dependencies – architecture clarification (Dec 2025)

> Internal architect note  
> This section clarifies that 1kUSD is deliberately **oracle-secured**.  
> It corrects external summaries that suggested an "oracle-free" target.

- 1kUSD is **not** oracle-free. Price feeds are a fundamental part of the
  economic design and are required by:
  - the PegStabilityModule (PSM) for pricing and limits,
  - the BuybackVault safety layer (A02) for health checks,
  - the guardian/safety stack for stress signalling.

- Disabling stale/diff checks for a given oracle **does not** mean
  the PSM can operate without a price feed. A PSM without a valid price
  feed is considered **economically broken** and must be treated as a
  configuration error.

- Any future "Kaspa-native" deployments must therefore still assume
  oracle-secured behaviour at the protocol layer. Reducing oracle
  surface area is a valid goal; removing oracles entirely is not.

This clarification is normative for future economic, integration and
governance documents.
EOD
  else
    echo "Economic overview already contains oracle clarification."
  fi
else
  echo "WARNING: $ECO_FILE not found, skipping economic-layer clarification."
fi

# 2) DEV-11 Telemetry outline – add new reason codes
TELE_FILE="docs/dev/DEV11_Telemetry_Events_Outline_r1.md"
if [ -f "$TELE_FILE" ]; then
  if ! grep -q "BUYBACK_ORACLE_REQUIRED" "$TELE_FILE"; then
    cat <<'EOD' >> "$TELE_FILE"

## Additional reason codes – Oracle & PSM dependencies (Dec 2025)

These codes formalise the fact that oracles are **required** for safe
operation of PSM and BuybackVault in strict modes.

- `BUYBACK_ORACLE_REQUIRED`  
  Emitted or implied when a buyback operation depends on oracle-sourced
  health information, but no valid oracle/health module is configured.
  In strict configurations this should cause a revert or a hard block.

- `PSM_ORACLE_MISSING`  
  Emitted or implied when the PegStabilityModule is asked to operate
  without a valid price feed for the relevant asset pair. This situation
  must be treated as a configuration failure and is not supported as a
  "no-oracle" operating mode.

Indexers and dashboards should treat these codes as **hard safety
signals**, not as soft warnings.
EOD
  else
    echo "Telemetry outline already contains BUYBACK_ORACLE_REQUIRED."
  fi
else
  echo "WARNING: $TELE_FILE not found, skipping telemetry update."
fi

# 3) Buyback observer guide – clarify OracleGate scope
OBS_FILE="docs/integrations/buybackvault_observer_guide.md"
if [ -f "$OBS_FILE" ]; then
  if ! grep -q "OracleGate scope clarification" "$OBS_FILE"; then
    cat <<'EOD' >> "$OBS_FILE"

## OracleGate scope clarification (Dec 2025)

The BuybackVault Oracle/Health gate (DEV-11 A02) is a **buyback-specific**
safety layer. It does not replace or duplicate PSM pricefeed logic.

- The OracleGate governs whether a **buyback** is allowed to proceed,
  based on oracle/health signals and guardian-configured policies.
- The PSM still relies on its own oracle-driven pricing logic as defined
  in the economic layer docs.

Observers and indexers should distinguish clearly between:

- PSM price-oracle failures (`PSM_ORACLE_MISSING` and related signals),
- BuybackVault health-gate rejections (`BUYBACK_ORACLE_UNHEALTHY`,
  `BUYBACK_ORACLE_REQUIRED`).

This separation is intentional and must be preserved in future
integrations.
EOD
  else
    echo "Buyback observer guide already contains OracleGate clarification."
  fi
else
  echo "WARNING: $OBS_FILE not found, skipping observer guide update."
fi

# 4) Release-flow plan (DEV-94) – messaging & oracle guardrails
REL_FILE="docs/dev/DEV94_ReleaseFlow_Plan_r2.md"
if [ -f "$REL_FILE" ]; then
  if ! grep -q "Release messaging guardrails" "$REL_FILE"; then
    cat <<'EOD' >> "$REL_FILE"

## Release messaging guardrails – Oracle & safety stack

To avoid misaligned external expectations, every release that touches
the economic layer or BuybackVault MUST verify:

- Documentation and public messaging do **not** describe 1kUSD as
  "oracle-free". The protocol is explicitly oracle-secured.
- The three safety layers (per-op cap A01, oracle/health gate A02,
  rolling window cap A03) are described as the **canonical** buyback
  safety stack, not as optional extras.
- StrategyEnforcement previews are clearly separated from the Phase A
  safety stack and are not marketed as a replacement for it.

These checks are part of the human review steps and complement the
technical `check_release_status.sh` gate.
EOD
  else
    echo "Release-flow plan already contains messaging guardrails."
  fi
else
  echo "WARNING: $REL_FILE not found, skipping release-flow update."
fi

# 5) Append log entry
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 40] ${timestamp} Added oracle & safety architecture clarifications (docs-only)" >> "$LOG_FILE"

echo "== DEV-9 40 done =="
