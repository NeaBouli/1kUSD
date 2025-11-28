#!/usr/bin/env bash
set -euo pipefail

VAULT_FILE="contracts/core/BuybackVault.sol"
TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV74 CORE01: add strategiesEnforced flag + setter + event =="

########################################
# 1) BuybackVault.sol erweitern
########################################
python3 - <<'PY'
from pathlib import Path

vault = Path("contracts/core/BuybackVault.sol")
text = vault.read_text()

changed = False

# 1a) strategiesEnforced-Flag nach strategies[] einfügen
if "bool public strategiesEnforced;" not in text:
    anchor = "StrategyConfig[] public strategies;"
    if anchor not in text:
        raise SystemExit("Anchor 'StrategyConfig[] public strategies;' not found in BuybackVault.sol")
    insert_pos = text.index(anchor) + len(anchor)
    add = "\n    bool public strategiesEnforced;\n"
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ strategiesEnforced flag added")
    changed = True

# 1b) StrategyEnforcementUpdated-Event vor StrategyUpdated einfügen
if "event StrategyEnforcementUpdated(bool enforced);" not in text:
    anchor = "event StrategyUpdated("
    if anchor not in text:
        raise SystemExit("Anchor 'event StrategyUpdated(' not found in BuybackVault.sol")
    insert_pos = text.index(anchor)
    add = "    event StrategyEnforcementUpdated(bool enforced);\n"
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ StrategyEnforcementUpdated event added")
    changed = True

# 1c) setStrategiesEnforced()-Setter vor setStrategy() einfügen
if "setStrategiesEnforced(" not in text:
    anchor = "    function setStrategy("
    if anchor not in text:
        raise SystemExit("Anchor 'function setStrategy(' not found in BuybackVault.sol")
    insert_pos = text.index(anchor)
    fn = """    function setStrategiesEnforced(bool enforced) external {
        if (msg.sender != dao) revert NOT_DAO();
        strategiesEnforced = enforced;
        emit StrategyEnforcementUpdated(enforced);
    }

"""
    text = text[:insert_pos] + fn + text[insert_pos:]
    print("✓ setStrategiesEnforced() added")
    changed = True

if changed:
    vault.write_text(text)
else:
    print("No changes required in BuybackVault.sol (already patched).")
PY

########################################
# 2) Tests in BuybackVault.t.sol
########################################
python3 - <<'PY'
from pathlib import Path

test = Path("foundry/test/BuybackVault.t.sol")
text = test.read_text()
changed = False

# 2a) Event-Deklaration einfügen
if "event StrategyEnforcementUpdated(bool enforced);" not in text:
    anchor = "event StrategyUpdated("
    if anchor not in text:
        raise SystemExit("Anchor 'event StrategyUpdated(' not found in BuybackVault.t.sol")
    insert_pos = text.index(anchor)
    decl = "    event StrategyEnforcementUpdated(bool enforced);\n"
    text = text[:insert_pos] + decl + text[insert_pos:]
    print("✓ StrategyEnforcementUpdated event declared in test")
    changed = True

# 2b) Tests nach testSetStrategyOnlyDao() einfügen
if "testStrategyEnforcementDefaultIsFalse" not in text:
    anchor = "function testSetStrategyOnlyDao()"
    if anchor not in text:
        raise SystemExit("Anchor 'function testSetStrategyOnlyDao()' not found in BuybackVault.t.sol")
    start = text.index(anchor)
    end = text.index("    }\n", start) + len("    }\n")

    add = """
    function testStrategyEnforcementDefaultIsFalse() public {
        assertFalse(vault.strategiesEnforced(), "default enforcement should be false");
    }

    function testSetStrategiesEnforcedOnlyDao() public {
        // DAO kann Flag setzen
        vm.prank(dao);
        vm.expectEmit(false, false, false, false);
        emit StrategyEnforcementUpdated(true);
        vault.setStrategiesEnforced(true);

        assertTrue(vault.strategiesEnforced(), "enforcement flag should be true");

        // Nicht-DAO darf Flag nicht ändern
        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.setStrategiesEnforced(false);
    }

"""
    text = text[:end] + add + text[end:]
    print("✓ StrategyEnforcement tests added to BuybackVault.t.sol")
    changed = True

if changed:
    test.write_text(text)
else:
    print("No changes required in BuybackVault.t.sol (already patched).")
PY

########################################
# 3) Log-Eintrag
########################################
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-74] ${timestamp} BuybackVault: added strategiesEnforced flag + setStrategiesEnforced() + StrategyEnforcementUpdated event with tests." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV74 CORE01: done =="
