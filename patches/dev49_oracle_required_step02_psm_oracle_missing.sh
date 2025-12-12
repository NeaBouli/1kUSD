#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

###############################################################################
# 1) PegStabilityModule: PSM_ORACLE_MISSING + harte Oracle-Pflicht
###############################################################################
python - << 'PY'
from pathlib import Path

path = Path("contracts/core/PegStabilityModule.sol")
text = path.read_text()

# 1a) Neue Error-Definition hinzufügen
old_err = """    event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);

    error PausedError();
    error InsufficientOut();
"""
new_err = """    event FeesUpdated(uint256 mintFeeBps, uint256 redeemFeeBps);

    error PausedError();
    error InsufficientOut();
    error PSM_ORACLE_MISSING();
"""
if old_err not in text:
    raise SystemExit("anchor for error block not found in PegStabilityModule.sol")
text = text.replace(old_err, new_err, 1)

# 1b) _requireOracleHealthy: fehlende Oracle-Konfiguration wird hart als Fehler gewertet
old_req = """    /// @dev Light health gate: ensures oracle is operational if configured.
    function _requireOracleHealthy(address /*token*/) internal view {
        if (address(oracle) == address(0)) {
            // No oracle configured → do not block swaps (bootstrap/dev mode).
            return;
        }
        require(oracle.isOperational(), "PSM: oracle not operational");
    }
"""
new_req = """    /// @dev Light health gate: ensures oracle is operational and present.
    ///      From DEV-49 onward, operating the PSM without a configured oracle
    ///      is treated as a configuration error and will revert.
    function _requireOracleHealthy(address /*token*/) internal view {
        if (address(oracle) == address(0)) {
            revert PSM_ORACLE_MISSING();
        }
        require(oracle.isOperational(), "PSM: oracle not operational");
    }
"""
if old_req not in text:
    raise SystemExit("anchor for _requireOracleHealthy not found in PegStabilityModule.sol")
text = text.replace(old_req, new_req, 1)

# 1c) _getPrice: kein Fallback mehr, sondern PSM_ORACLE_MISSING
old_price = """    /// @notice Fetch price for an asset from the oracle.
    /// @dev Returns (price, decimals) where `price` is scaled by `decimals`.
    function _getPrice(address asset) internal view returns (uint256 price, uint8 priceDecimals) {
        if (address(oracle) == address(0)) {
            // Fallback: 1.0 * 10^18 (1 token == 1 1kUSD) for tests/bootstrap.
            return (1e18, 18);
        }

        IOracleAggregator.Price memory p = oracle.getPrice(asset);
        require(p.healthy, "PSM: oracle unhealthy");
        require(p.price > 0, "PSM: bad price");

        return (uint256(p.price), p.decimals);
    }
"""
new_price = """    /// @notice Fetch price for an asset from the oracle.
    /// @dev Returns (price, decimals) where `price` is scaled by `decimals`.
    ///      From DEV-49 onward, a missing oracle is treated as a hard error.
    function _getPrice(address asset) internal view returns (uint256 price, uint8 priceDecimals) {
        if (address(oracle) == address(0)) {
            revert PSM_ORACLE_MISSING();
        }

        IOracleAggregator.Price memory p = oracle.getPrice(asset);
        require(p.healthy, "PSM: oracle unhealthy");
        require(p.price > 0, "PSM: bad price");

        return (uint256(p.price), p.decimals);
    }
"""
if old_price not in text:
    raise SystemExit("anchor for _getPrice not found in PegStabilityModule.sol")
text = text.replace(old_price, new_price, 1)

path.write_text(text)
PY

###############################################################################
# 2) PSMRegression_Limits: echten 1:1-Oracle anschließen
###############################################################################
python - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Limits.t.sol")
text = path.read_text()

# 2a) Oracle-Storage-Var einfügen (falls noch nicht vorhanden)
if "MockOracleAggregator public oracle;" not in text:
    anchor = (
        "    OneKUSD public oneKUSD;\n"
        "    MockERC20 public collateralToken;\n"
        "    MockCollateralVault public vault;\n"
        "    ParameterRegistry public reg;\n"
    )
    if anchor not in text:
        raise SystemExit("state var anchor not found in PSMRegression_Limits")
    repl = anchor + "    MockOracleAggregator public oracle;\n"
    text = text.replace(anchor, repl, 1)

# 2b) In setUp nach PSM-Konstruktion 1:1-Oracle setzen
marker = """        // 2) PegStabilityModule with real vault/registry, no safety automata
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(reg)
        );
"""
if marker not in text:
    raise SystemExit("setUp marker not found in PSMRegression_Limits")
insert = marker + """
        // 2b) Oracle 1:1 price (required from DEV-49 onwards)
        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));
"""
text = text.replace(marker, insert, 1)

path.write_text(text)
PY

###############################################################################
# 3) PSMRegression_Fees: Oracle-Mock importieren & setzen
###############################################################################
python - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Fees.t.sol")
text = path.read_text()

# 3a) Import für MockOracleAggregator ergänzen
if "MockOracleAggregator" not in text:
    import_anchor = (
        'import {MockERC20} from "../mocks/MockERC20.sol";\n'
        'import {MockCollateralVault} from "../mocks/MockCollateralVault.sol";\n'
    )
    if import_anchor not in text:
        raise SystemExit("import anchor not found in PSMRegression_Fees")
    import_block = import_anchor + 'import {MockOracleAggregator} from "../mocks/MockOracleAggregator.sol";\n'
    text = text.replace(import_anchor, import_block, 1)

# 3b) Oracle-Var im Storage
state_anchor = (
    "    PegStabilityModule internal psm;\n"
    "    OneKUSD internal oneKUSD;\n"
    "    ParameterRegistry internal registry;\n"
    "    MockERC20 internal collateralToken;\n"
    "    MockCollateralVault internal vault;\n"
)
if "MockOracleAggregator internal oracle;" not in text:
    if state_anchor not in text:
        raise SystemExit("state anchor not found in PSMRegression_Fees")
    state_block = state_anchor + "    MockOracleAggregator internal oracle;\n"
    text = text.replace(state_anchor, state_block, 1)

# 3c) In setUp Oracle setzen
marker = """        // PSM mit echtem Vault + Registry, aber ohne Safety/Oracle (Fallback-Preis 1.0)
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(registry)
        );
"""
if marker not in text:
    raise SystemExit("setUp marker not found in PSMRegression_Fees")
replacement = """        // PSM mit echtem Vault + Registry, Oracle wird explizit auf 1:1 gesetzt.
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(0),
            address(registry)
        );

        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));
"""
text = text.replace(marker, replacement, 1)

path.write_text(text)
PY

###############################################################################
# 4) PSMRegression_Spreads: Oracle-Mock importieren & setzen
###############################################################################
python - << 'PY'
from pathlib import Path

path = Path("foundry/test/psm/PSMRegression_Spreads.t.sol")
text = path.read_text()

# 4a) Import für MockOracleAggregator ergänzen
if "MockOracleAggregator" not in text:
    import_anchor = (
        'import "../../../contracts/core/SafetyAutomata.sol";\n'
        'import "@openzeppelin/contracts/token/ERC20/ERC20.sol";\n'
    )
    if import_anchor not in text:
        raise SystemExit("import anchor not found in PSMRegression_Spreads")
    import_block = import_anchor + 'import "../mocks/MockOracleAggregator.sol";\n'
    text = text.replace(import_anchor, import_block, 1)

# 4b) Oracle-Var im Storage
state_anchor = (
    "    ParameterRegistry internal registry;\n"
    "    SafetyAutomata internal safety;\n"
    "    PegStabilityModule internal psm;\n"
    "    MockVault internal vault;\n"
    "    MockMintableToken internal collateralToken;\n"
    "    MockMintableToken internal oneKUSD;\n"
)
if "MockOracleAggregator internal oracle;" not in text:
    if state_anchor not in text:
        raise SystemExit("state anchor not found in PSMRegression_Spreads")
    state_block = state_anchor + "    MockOracleAggregator internal oracle;\n"
    text = text.replace(state_anchor, state_block, 1)

# 4c) In setUp Oracle setzen
marker = """        // PSM mit Registry + Safety + Vault, Oracle bleibt auf Fallback (1e18, 18 Decimals)
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );
"""
if marker not in text:
    raise SystemExit("setUp marker not found in PSMRegression_Spreads")
replacement = """        // PSM mit Registry + Safety + Vault, Oracle explizit auf 1:1 gesetzt (1e18, 18 Decimals)
        psm = new PegStabilityModule(
            dao,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );

        oracle = new MockOracleAggregator();
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));
"""
text = text.replace(marker, replacement, 1)

path.write_text(text)
PY

###############################################################################
# 5) Log-Eintrag
###############################################################################
echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add PSM_ORACLE_MISSING to PegStabilityModule and wire oracle into PSM regression tests" >> logs/project.log

echo "== DEV-49 step02: PSM_ORACLE_MISSING wired into PegStabilityModule and PSM regression tests updated =="
