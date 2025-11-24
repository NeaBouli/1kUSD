#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/buybackvault_plan.md"

echo "== DEV62 DOC01: append implementation status checklist to BuybackVault plan =="

cat <<'EOL' >> "$FILE"

---

## 5. Implementierungsstatus (DEV-60 ff.)

Diese Checkliste spiegelt den aktuellen Stand im Repo wider:

- [x] **Stage A – Custody & Safety-Baseline**
  - BuybackVault.sol angelegt (DAO-verwalteter Stable- & Asset-Pool).
  - Nur DAO darf Stable/Asset in den Vault verschieben.
  - Safety-Pause wird respektiert (fund/withdraw blockiert, wenn Modul pausiert ist).
  - Regression-Tests: \`foundry/test/BuybackVault.t.sol\` (Constructor, DAO-only, Zero-Address-Guards, Balance-Views).

- [ ] **Stage B – Swap- & Buyback-Strategie**
  - Routing über DEX/AMM (z. B. Uniswap-ähnliche Pools) für Stable → Asset.
  - Konfigurierbare Ziel- und Max-Slippage-Parameter (z. B. über ParameterRegistry / eigene Keys).
  - Event- und Telemetrie-Hooks für Indexer/Monitoring.
  - Regression-Tests für Preis-Impact, Slippage-Gates und Failover-Verhalten.

- [ ] **Stage C – Governance, Limits & Automatisierung**
  - Governance-Gebundenheit (DAO/Timelock) für Buyback-Parameter (Frequenz, Max-Volumen, DEX-Whitelists).
  - Limits pro Periode (ähnlich PSMLimits) für maximale Buyback-Notional/Tag.
  - Integration in Governance-Proposal-Flow (JSON-Vorlagen, How-To).
  - Langfristig: Watchdog/Guardian, der Buybacks pausiert, wenn Oracle/Safety-Signale kritisch werden.

Hinweis: Stage A ist mit DEV-60/61 abgeschlossen, Stage B und C sind bewusst als nächste Iterationen offen gelassen.
EOL

echo "✓ BuybackVault Implementierungsstatus an $FILE angehängt"
