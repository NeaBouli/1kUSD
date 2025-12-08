#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="foundry/test/BuybackVault.t.sol"

python - << 'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

# 1) OracleHealthStub vor BuybackVaultTest einfügen (nur wenn noch nicht vorhanden)
if "contract OracleHealthStub" not in text:
    marker = "contract BuybackVaultTest is Test {"
    stub = """
contract OracleHealthStub {
    bool public healthy;

    function setHealthy(bool value) external {
        healthy = value;
    }

    function isHealthy() external view returns (bool) {
        return healthy;
    }
}

"""
    if marker not in text:
        raise SystemExit("Marker for BuybackVaultTest not found")
    text = text.replace(marker, stub + marker)

# 2) Phase-B-Tests nur einmal einfügen
if "testExecuteBuybackPSM_OracleGate_EnforcedWithoutModuleReverts" not in text:
    insert = """
    // --- Phase B: Oracle health gate telemetry tests ---

    function _configureOracleGate(address module, bool enforced) internal {
        vm.prank(dao);
        vault.setOracleHealthGateConfig(module, enforced);
    }

    function _fundAndPrepareOracleGate(uint256 amount, address module, bool enforced) internal {
        _fundStableAsDao(amount);
        _configureOracleGate(module, enforced);
    }

    function testExecuteBuybackPSM_OracleGate_EnforcedWithoutModuleReverts() public {
        uint256 amount = 1e18;
        _fundStableAsDao(amount);

        _configureOracleGate(address(0), true);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.BUYBACK_ORACLE_UNHEALTHY.selector);
        vault.executeBuybackPSM(amount / 2, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackPSM_OracleGate_DisabledIgnoresMissingModule() public {
        uint256 amount = 1e18;
        _fundStableAsDao(amount);

        _configureOracleGate(address(0), false);

        vm.prank(dao);
        uint256 outAmount = vault.executeBuybackPSM(amount / 2, user, 0, block.timestamp + 1 days);
        assertGt(outAmount, 0);
    }

    function testExecuteBuybackPSM_OracleGate_HealthyModuleAllowsBuyback() public {
        uint256 amount = 1e18;
        OracleHealthStub health = new OracleHealthStub();
        health.setHealthy(true);

        _fundAndPrepareOracleGate(amount, address(health), true);

        vm.prank(dao);
        uint256 outAmount = vault.executeBuybackPSM(amount / 2, user, 0, block.timestamp + 1 days);
        assertGt(outAmount, 0);
    }

    function testExecuteBuybackPSM_OracleGate_UnhealthyModuleReverts() public {
        uint256 amount = 1e18;
        OracleHealthStub health = new OracleHealthStub();
        health.setHealthy(false);

        _fundAndPrepareOracleGate(amount, address(health), true);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.BUYBACK_ORACLE_UNHEALTHY.selector);
        vault.executeBuybackPSM(amount / 2, user, 0, block.timestamp + 1 days);
    }
"""
    idx = text.rfind("}")
    if idx == -1:
        raise SystemExit("Could not find closing brace in BuybackVault.t.sol")

    # vor der letzten schließenden Klammer der Test-Contract-Klasse einfügen
    text = text[:idx] + insert + "\n}\n"

path.write_text(text)
PY

# Log-Eintrag für Phase B Telemetry Step 01
echo "[DEV-11 PhaseB] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add oracle health gate telemetry tests for BuybackVault" >> logs/project.log

echo "== DEV-11 Phase B: oracle gate telemetry tests added =="
