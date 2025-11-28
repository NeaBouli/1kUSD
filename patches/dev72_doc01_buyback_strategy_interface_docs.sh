#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/buybackvault_strategy.md"
LOG_FILE="logs/project.log"

echo "== DEV72 DOC01: document IBuybackStrategy in BuybackVault strategy architecture =="

python3 - <<'PY'
from pathlib import Path

path = Path("docs/architecture/buybackvault_strategy.md")
text = path.read_text()

snippet = """
## 7. Strategy modules interface (forward-looking)

In version v0.51.0 the BuybackVault exposes only a minimal on-vault
`StrategyConfig` (asset / weightBps / enabled). For future versions
(v0.52+ RFC) external strategy modules can be introduced via a dedicated
`IBuybackStrategy` interface in `contracts/strategy/IBuybackStrategy.sol`.

This interface allows:

- the vault (or a coordinator) to query a strategy contract for a list of
  proposed buyback legs (`BuybackLeg[]`),
- offloading allocation logic and policy rules into upgradable,
  separately-auditable contracts,
- keeping the core vault logic small and focused on execution and safety.

At this stage, `IBuybackStrategy` is defined but *not yet wired* into the
BuybackVault execution path; it serves as a design anchor for future
multi-asset / policy-based buyback phases.
"""

if "Strategy modules interface (forward-looking)" in text:
    print("Snippet already present; no change.")
else:
    if not text.endswith("\n"):
        text += "\n"
    text = text + snippet + "\n"
    path.write_text(text)
    print("✓ buybackvault_strategy.md updated with IBuybackStrategy section.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-72] ${timestamp} Strategy: documented IBuybackStrategy interface in buybackvault_strategy.md." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV72 DOC01: done =="
