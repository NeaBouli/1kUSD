#!/usr/bin/env bash
set -euo pipefail

VAULT_FILE="contracts/core/BuybackVault.sol"
TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV70 CORE01: add BuybackVault strategy config (storage + events + tests) =="

########################################
# 1) BuybackVault.sol erweitern
########################################

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()

# 1.1 Fehler INVALID_STRATEGY deklarieren
if "error INVALID_STRATEGY();" not in text:
    anchor = "error INSUFFICIENT_BALANCE();"
    if anchor not in text:
        raise SystemExit("Anchor 'error INSUFFICIENT_BALANCE();' not found in BuybackVault.sol")
    insert_pos = text.index(anchor) + len(anchor)
    add = "\nerror INVALID_STRATEGY();"
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ INVALID_STRATEGY error declared in BuybackVault.sol")
else:
    print("INVALID_STRATEGY already declared, skipping.")

# 1.2 Event StrategyUpdated deklarieren
if "event StrategyUpdated(" not in text:
    anchor = "event BuybackExecuted("
    if anchor not in text:
        raise SystemExit("Anchor 'event BuybackExecuted(' not found in BuybackVault.sol")
    insert_pos = text.index(anchor)
    # Am Ende der BuybackExecuted-Event-Zeile einfügen
    end = text.index(";", insert_pos) + 1
    add = "\n    event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);"
    text = text[:end] + add + text[end:]
    print("✓ StrategyUpdated event declared in BuybackVault.sol")
else:
    print("StrategyUpdated already declared, skipping.")

# 1.3 StrategyConfig-Struct + Storage hinzufügen
if "struct StrategyConfig" not in text:
    anchor = "bytes32 public moduleId;"
    if anchor not in text:
        raise SystemExit("Anchor 'bytes32 public moduleId;' not found in BuybackVault.sol")
    insert_pos = text.index(anchor) + len(anchor)
    add = """

    struct StrategyConfig {
        address asset;
        uint16 weightBps;
        bool enabled;
    }

    StrategyConfig[] private strategies;
"""
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ StrategyConfig struct + storage added to BuybackVault.sol")
else:
    print("StrategyConfig already present, skipping.")

# 1.4 Strategy-Funktionen hinzufügen (Count, Get, Set)
if "function strategyCount()" not in text:
    anchor = "function stableBalance() external view returns (uint256)"
    if anchor not in text:
        raise SystemExit("Anchor 'function stableBalance() external view returns (uint256)' not found in BuybackVault.sol")
    insert_pos = text.index("function stableBalance() external view returns (uint256)")
    add = """    // --- Strategy config ---

    function strategyCount() external view returns (uint256) {
        return strategies.length;
    }

    function getStrategy(uint256 id) external view returns (StrategyConfig memory) {
        if (id >= strategies.length) revert INVALID_STRATEGY();
        return strategies[id];
    }

    function setStrategy(
        uint256 id,
        address asset_,
        uint16 weightBps_,
        bool enabled_
    ) external {
        if (msg.sender != dao) revert NOT_DAO();
        if (asset_ == address(0)) revert ZERO_ADDRESS();

        StrategyConfig memory cfg = StrategyConfig({
            asset: asset_,
            weightBps: weightBps_,
            enabled: enabled_
        });

        if (id == strategies.length) {
            strategies.push(cfg);
        } else if (id < strategies.length) {
            strategies[id] = cfg;
        } else {
            revert INVALID_STRATEGY();
        }

        emit StrategyUpdated(id, asset_, weightBps_, enabled_);
    }

"""
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ strategyCount/getStrategy/setStrategy added to BuybackVault.sol")
else:
    print("Strategy functions already present, skipping.")

path.write_text(text)
PY

########################################
# 2) Tests in BuybackVault.t.sol ergänzen
########################################

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

if "testSetStrategyOnlyDao" in text:
    print("Strategy config tests already present, skipping.")
else:
    anchor = "    // --- View Helpers ---"
    if anchor not in text:
        raise SystemExit("Anchor '// --- View Helpers ---' not found in BuybackVault.t.sol")

    insert_pos = text.index(anchor)
    add = """
    // --- Strategy config tests ---

    function testSetStrategyOnlyDao() public {
        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.setStrategy(0, address(asset), 10000, true);
    }

    function testSetStrategyCreateAndUpdate() public {
        vm.prank(dao);
        vault.setStrategy(0, address(asset), 5000, true);

        assertEq(vault.strategyCount(), 1, "strategyCount should be 1");

        BuybackVault.StrategyConfig memory cfg = vault.getStrategy(0);
        assertEq(cfg.asset, address(asset), "asset mismatch");
        assertEq(cfg.weightBps, 5000, "weight mismatch");
        assertTrue(cfg.enabled, "enabled mismatch");

        vm.prank(dao);
        vault.setStrategy(0, address(asset), 7500, false);

        cfg = vault.getStrategy(0);
        assertEq(cfg.weightBps, 7500, "updated weight mismatch");
        assertFalse(cfg.enabled, "updated enabled mismatch");
    }

    function testSetStrategyInvalidIdReverts() public {
        vm.prank(dao);
        vm.expectRevert(BuybackVault.INVALID_STRATEGY.selector);
        vault.setStrategy(2, address(asset), 5000, true);
    }

    function testGetStrategyOutOfRangeReverts() public {
        vm.expectRevert(BuybackVault.INVALID_STRATEGY.selector);
        vault.getStrategy(0);
    }

"""
    text = text[:insert_pos] + add + text[insert_pos:]
    path.write_text(text)
    print("✓ Strategy config tests added to BuybackVault.t.sol")
PY

########################################
# 3) Log-Eintrag
########################################

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-70] ${timestamp} BuybackVault: added StrategyConfig storage + strategyCount/getStrategy/setStrategy with regression tests." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 CORE01: done =="
