#!/usr/bin/env bash
set -euo pipefail

VAULT_FILE="contracts/core/BuybackVault.sol"
TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV70 CORE03: fix INVALID_STRATEGY / StrategyUpdated + add strategy tests =="

########################################
# 1) BuybackVault.sol: Error + Event nachziehen
########################################

python3 - <<'PY'
from pathlib import Path

path = Path("contracts/core/BuybackVault.sol")
text = path.read_text()
modified = False

# 1.1 INVALID_STRATEGY error deklarieren
if "error INVALID_STRATEGY();" not in text:
    # wir hängen ihn hinter INSUFFICIENT_BALANCE oder PAUSED an
    anchors = [
        "error INSUFFICIENT_BALANCE();",
        "error INVALID_AMOUNT();",
        "error PAUSED();",
    ]
    insert_pos = None
    for a in anchors:
        if a in text:
            insert_pos = text.index(a) + len(a)
            break
    if insert_pos is None:
        raise SystemExit("No suitable error anchor found in BuybackVault.sol")

    add = "\nerror INVALID_STRATEGY();"
    text = text[:insert_pos] + add + text[insert_pos:]
    modified = True
    print("✓ INVALID_STRATEGY error declared in BuybackVault.sol")
else:
    print("INVALID_STRATEGY already declared, skipping.")

# 1.2 StrategyUpdated event deklarieren
if "event StrategyUpdated(" not in text:
    anchor = "event BuybackExecuted("
    if anchor not in text:
        raise SystemExit("Anchor 'event BuybackExecuted(' not found in BuybackVault.sol")

    insert_pos = text.index(anchor)
    add = "event StrategyUpdated(uint256 indexed id, address asset, uint16 weightBps, bool enabled);\n    "
    text = text[:insert_pos] + add + text[insert_pos:]
    modified = True
    print("✓ StrategyUpdated event declared in BuybackVault.sol")
else:
    print("StrategyUpdated already declared, skipping.")

if modified:
    path.write_text(text)
PY

########################################
# 2) Strategie-Tests in BuybackVault.t.sol ergänzen
########################################

python3 - <<'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

if "testSetStrategyOnlyDao" in text:
    print("Strategy config tests already present in BuybackVault.t.sol, skipping.")
else:
    # Wir hängen die Strategie-Tests VOR den View-Helper-Test
    anchor = "    function testBalanceViewsReflectHoldings() public {"
    if anchor not in text:
        raise SystemExit("Anchor 'function testBalanceViewsReflectHoldings()' not found in BuybackVault.t.sol")

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
echo "[DEV-70] ${timestamp} BuybackVault: wired INVALID_STRATEGY + StrategyUpdated and added strategy config tests." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV70 CORE03: done =="
