#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== DEV-11 A01: add tests for per-operation treasury cap =="

TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "$TS DEV-11 A01: add tests for per-operation treasury cap" >> logs/project.log

python3 - << 'PY'
from pathlib import Path

path = Path("foundry/test/BuybackVault.t.sol")
text = path.read_text()

idx = text.rfind("}")
if idx == -1:
    raise SystemExit("Could not find closing brace in BuybackVault.t.sol")

new_tests = '''
    // --- Phase A: per-operation treasury cap ---

    function testSetMaxBuybackSharePerOpBpsOnlyDao() public {
        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.setMaxBuybackSharePerOpBps(5000);
    }

    function testSetMaxBuybackSharePerOpBpsBounds() public {
        vm.prank(dao);
        vault.setMaxBuybackSharePerOpBps(0);
        assertEq(vault.maxBuybackSharePerOpBps(), 0, "cap should be zero");

        vm.prank(dao);
        vault.setMaxBuybackSharePerOpBps(10_000);
        assertEq(vault.maxBuybackSharePerOpBps(), 10_000, "cap should be 100%");

        vm.prank(dao);
        vm.expectRevert(BuybackVault.INVALID_AMOUNT.selector);
        vault.setMaxBuybackSharePerOpBps(10_001);
    }

    function testExecuteBuybackPSMRespectsPerOpTreasuryCap() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vault.setMaxBuybackSharePerOpBps(5000); // 50%

        vm.prank(dao);
        vm.expectRevert(BuybackVault.BUYBACK_TREASURY_CAP_EXCEEDED.selector);
        vault.executeBuybackPSM(6e18, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackPSMWithinPerOpCapSucceeds() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vault.setMaxBuybackSharePerOpBps(5000); // 50%

        uint256 amount1k = 4e18;
        uint256 vaultStableBefore = stable.balanceOf(address(vault));
        uint256 userAssetBefore = asset.balanceOf(user);

        vm.prank(dao);
        uint256 out = vault.executeBuybackPSM(
            amount1k,
            user,
            0,
            block.timestamp + 1 days
        );

        assertEq(out, amount1k, "buyback out should be 1:1 in stub");
        assertEq(
            stable.balanceOf(address(vault)),
            vaultStableBefore - amount1k,
            "vault stable balance mismatch"
        );
        assertEq(
            asset.balanceOf(user) - userAssetBefore,
            amount1k,
            "user asset balance mismatch"
        );
    }
'''
new_text = text[:idx] + new_tests + "\n" + text[idx:]
path.write_text(new_text)
PY

forge test --match-path foundry/test/BuybackVault.t.sol
mkdocs build

echo "== DEV-11 A01 cap tests done =="
