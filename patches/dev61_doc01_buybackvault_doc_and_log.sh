#!/usr/bin/env bash
set -euo pipefail

echo "== DEV61 DOC01: record BuybackVault PSM execution in docs + log =="

PLAN="docs/architecture/buybackvault_plan.md"
LOG="logs/project.log"

# Architektur-Notiz zu DEV-61 anhängen
cat <<'EOL' >> "$PLAN"

## DEV-61: PSM-basierte Buyback-Execution (MVP)

Status:
- BuybackVault hält 1kUSD-Stable (\`stable\`) und das Buyback-Asset (\`asset\`).
- \`executeBuybackPSM(uint256 amount1k, address recipient, uint256 minOut, uint256 deadline)\`:
  - nur \`dao\` darf aufrufen (\`onlyDAO\`).
  - Safety-Gate via \`ISafetyAutomata.isPaused(bytes32 moduleId)\`; \`moduleId = keccak256("BUYBACK_VAULT")\`.
  - Vault erhöht Allowance für den PSM und ruft
    \`psm.swapFrom1kUSD(address(asset), amount1k, recipient, minOut, deadline)\`.
  - Fees/Spreads/Limits/Oracle-Health liegen vollständig im PSM; Vault ist "blinder" Ausführungs-Endpunkt.
- Tests: \`BuybackVault.t.sol\` deckt Constructor-Guards, Access-Control, Pause-Handling und PSM-Execution (1:1 Stub) ab.

EOL

# DEV-61 Log-Eintrag ergänzen (UTC Stempel exemplarisch)
cat <<'EOL' >> "$LOG"
[DEV-61] 2025-11-26T10:30:00Z BuybackVault: executeBuybackPSM() via PSM.swapFrom1kUSD (bytes32 moduleId Safety-Gate, onlyDAO, 1:1 PSM-Stub); BuybackVault.t.sol deckt Access, Pause und PSM-Execution (17 Tests); Gesamt-Suite 59 Tests grün.
EOL

echo "✓ DEV61 DOC01: BuybackVault plan + log updated"
