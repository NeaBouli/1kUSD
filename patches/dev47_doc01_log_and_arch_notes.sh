#!/usr/bin/env bash
set -euo pipefail

LOG="logs/project.log"
DOC="docs/architecture/psm_dev43-45.md"

echo "== DEV47 DOC01: log + architecture notes for ParameterRegistry-decimals =="

mkdir -p "$(dirname "$LOG")"
mkdir -p "$(dirname "$DOC")"

# 1) Log-Eintrag für DEV-47 (Decimals via ParameterRegistry)
cat <<EOL >> "$LOG"
[DEV-47] $(date -u +"%Y-%m-%dT%H:%M:%SZ") PSM: token decimals now fetched via ParameterRegistry (per-token keys, 18-dec fallback when unset or no registry); Guardian_PSMUnpause wired to null registry to keep pause/unpause semantics independent from decimals config.
EOL

# 2) Architektur-Notiz ans Ende der bestehenden PSM-Doku anhängen
cat <<'EOL' >> "$DOC"

---

## DEV-47 – Token-Decimals via ParameterRegistry

**Ziel:**  
Die PSM-Notional-Mathe sollte nicht länger implizit von `18` Token-Decimals ausgehen, sondern die tatsächlichen Decimals pro Collateral-Asset aus einer on-chain Registry ziehen.

### Umsetzung

- Neue Konstante und Helper in `PegStabilityModule`:
  - `KEY_TOKEN_DECIMALS = keccak256("psm:tokenDecimals")`
  - `_tokenDecimalsKey(address token)` → `bytes32`-Key pro Asset.
  - `_getTokenDecimals(address token)`:
    - Wenn `registry == address(0)` → Fallback auf `18`.
    - Sonst: `registry.getUint(_tokenDecimalsKey(token))`.
    - Wenn Wert `0` → ebenfalls Fallback auf `18`.
    - Guard: `raw <= type(uint8).max` (sonst Revert `"PSM: bad tokenDecimals"`).

- `swapTo1kUSD`:
  - Statt fix `uint8 tokenInDecimals = 18;`
  - Jetzt: `uint8 tokenInDecimals = _getTokenDecimals(tokenIn);`

- `swapFrom1kUSD`:
  - Statt fix `uint8 tokenOutDecimals = 18;`
  - Jetzt: `uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);`

### Guardian-/Safety-Kompatibilität

- `Guardian_PSMUnpause.t.sol` wurde bewusst **registry-frei** gehalten:
  - PSM-Konstruktor erhält als letztes Argument `address(0)` für die Registry.
  - Damit nutzt `_getTokenDecimals()` im Test immer den 18-Decimals-Fallback.
  - Der Test prüft weiterhin ausschließlich:
    - Pause/Unpause über `SafetyAutomata`.
    - Dass ein Swap nach `resumeModule()` **nicht reverted**.

### Auswirkungen auf spätere Integrationen

- Collateral-Assets mit != 18 Decimals (z. B. 6 oder 8) können nun sauber verdrahtet werden, indem der DAO/Timelock:
  - Für jedes Asset `registry.setUint(_tokenDecimalsKey(asset), decimals)` setzt.
- Die bestehende Notional-Mathe (DEV-44) bleibt unverändert:
  - `_normalizeTo1kUSD` / `_normalizeFrom1kUSD` nutzen jetzt nur noch die Registry-Decimals statt eines Fixwerts.
- L1-Migration bleibt unkritisch:
  - Registry-Keys sind rein logisch; der Mapping-Ansatz funktioniert auch jenseits von EVM, solange eine Key→Value-Map existiert.

EOL

echo "✓ DEV-47 log entry added and architecture notes appended to $DOC"
