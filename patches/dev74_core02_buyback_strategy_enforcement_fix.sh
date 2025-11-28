#!/usr/bin/env bash
set -euo pipefail

VAULT_FILE="contracts/core/BuybackVault.sol"
TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV74 CORE02: fix strategiesEnforced flag + tests =="

########################################
# 1) BuybackVault.sol anpassen
########################################
python3 - <<'PY'
from pathlib import Path

vault = Path("contracts/core/BuybackVault.sol")
text = vault.read_text()
changed = False

# 1a) strategiesEnforced-Flag nach dem strategies[]-Storage deklarieren
if "bool public strategiesEnforced;" not in text:
    # Suche generisch nach der StrategyConfig-Array-Deklaration
    idx = text.find("StrategyConfig[]")
    if idx == -1:
        raise SystemExit("Could not find 'StrategyConfig[]' in BuybackVault.sol")

    # finde das Semikolon hinter der Deklaration
    semi = text.find(";", idx)
    if semi == -1:
        raise SystemExit("Could not find semicolon after 'StrategyConfig[]' declaration")

    insert_pos = semi + 1
    add = "\n    bool public strategiesEnforced;\n"
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ strategiesEnforced flag added")
    changed = True
else:
    print("strategiesEnforced flag already present")

# 1b) StrategyEnforcementUpdated-Event vor StrategyUpdated einfügen
if "event StrategyEnforcementUpdated(bool enforced);" not in text:
    anchor = "event StrategyUpdated("
    pos = text.find(anchor)
    if pos == -1:
        raise SystemExit("Anchor 'event StrategyUpdated(' not found in BuybackVault.sol")
    insert_pos = pos
    add = "    event StrategyEnforcementUpdated(bool enforced);\n"
    text = text[:insert_pos] + add + text[insert_pos:]
    print("✓ StrategyEnforcementUpdated event added")
    changed = True
else:
    print("StrategyEnforcementUpdated event already present")

# 1c) setStrategiesEnforced()-Setter vor setStrategy() einfügen
if "setStrategiesEnforced(" not in text:
    anchor = "function setStrategy("
    pos = text.find(anchor)
    if pos == -1:
        raise SystemExit("Anchor 'function setStrategy(' not found in BuybackVault.sol")
    insert_pos = text.rfind("\n", 0, pos)
    if insert_pos == -1:
        insert_pos = pos
    fn = """
    function setStrategiesEnforced(bool enforced) external {
        if (msg.sender != dao) revert NOT_DAO();
        strategiesEnforced = enforced;
        emit StrategyEnforcementUpdated(enforced);
    }

"""
    text = text[:insert_pos+1] + fn + text[insert_pos+1:]
    print("✓ setStrategiesEnforced() added")
    changed = True
else:
    print("setStrategiesEnforced() already present")

if changed:
    vault.write_text(text)
else:
    print("No changes required in BuybackVault.sol (already patched).")
PY

########################################
# 2) Tests in BuybackVault.t.sol ergänzen
########################################
python3 - <<'PY'
from pathlib import Path

test = Path("foundry/test/BuybackVault.t.sol")
text = test.read_text()
changed = False

# 2a) Event-Deklaration in Testvertrag
if "event StrategyEnforcementUpdated(bool enforced);" not in text:
    anchor = "event StrategyUpdated("
    pos = text.find(anchor)
    if pos == -1:
        raise SystemExit("Anchor 'event StrategyUpdated(' not found in BuybackVault.t.sol")
    insert_pos = pos
    decl = "    event StrategyEnforcementUpdated(bool enforced);\n"
    text = text[:insert_pos] + decl + text[insert_pos:]
    print("✓ StrategyEnforcementUpdated event declared in test")
    changed = True
else:
    print("StrategyEnforcementUpdated event already declared in test")

# 2b) Tests nach testSetStrategyOnlyDao() einfügen
if "testStrategyEnforcementDefaultIsFalse" not in text:
    anchor = "function testSetStrategyOnlyDao()"
    pos = text.find(anchor)
    if pos == -1:
        raise SystemExit("Anchor 'function testSetStrategyOnlyDao()' not found in BuybackVault.t.sol")
    # Ende dieser Funktion finden
    end = text.find("    }\n", pos)
    if end == -1:
        raise SystemExit("Could not find end of testSetStrategyOnlyDao()")
    end += len("    }\n")

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
else:
    print("StrategyEnforcement tests already present")

if changed:
    test.write_text(text)
else:
    print("No changes required in BuybackVault.t.sol (already patched).")
PY

########################################
# 3) Log-Eintrag
########################################
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-74] ${timestamp} BuybackVault: FIX strategiesEnforced flag + setStrategiesEnforced() + StrategyEnforcementUpdated event wired with tests." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV74 CORE02: done =="
