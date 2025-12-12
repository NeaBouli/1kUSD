// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BuybackVault, IPegStabilityModuleLike} from "../../contracts/core/BuybackVault.sol";

contract MintableToken is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract SafetyStub {
    bool public paused;

    function setPaused(bool value) external {
        paused = value;
    }

    function isPaused(bytes32) external view returns (bool) {
        return paused;
    }
}

contract PSMStub is IPegStabilityModuleLike {
    MintableToken public immutable stable;
    MintableToken public immutable asset;

    uint256 public lastAmountIn;
    address public lastRecipient;

    constructor(MintableToken _stable, MintableToken _asset) {
        stable = _stable;
        asset = _asset;
    }

    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        address recipient,
        uint256 minOut,
        uint256
    ) external override returns (uint256 amountOut) {
        require(tokenOut == address(asset), "PSMStub: tokenOut mismatch");
        require(recipient != address(0), "PSMStub: zero recipient");

        // Ziehe 1kUSD vom Vault ein
        stable.transferFrom(msg.sender, address(this), amountIn1k);

        // Einfacher 1:1-Swap für Tests
        amountOut = amountIn1k;
        require(amountOut >= minOut, "PSMStub: slippage");

        asset.mint(recipient, amountOut);

        lastAmountIn = amountIn1k;
        lastRecipient = recipient;
    }
}


contract OracleHealthStub {
    bool public healthy;

    function setHealthy(bool value) external {
        healthy = value;
    }

    function isHealthy() external view returns (bool) {
        return healthy;
    }
}

contract BuybackVaultTest is Test {
    // Mirror BuybackVault events for vm.expectEmit
    event StableFunded(address indexed from, uint256 amount);
    event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);
    event StableWithdrawn(address indexed to, uint256 amount);
    event AssetWithdrawn(address indexed to, uint256 amount);

    MintableToken internal stable;
    MintableToken internal asset;
    SafetyStub internal safety;
    PSMStub internal psm;
    BuybackVault internal vault;

    address internal dao = address(0xDA0);
    address internal user = address(0xBEEF);
    bytes32 internal constant MODULE_ID = keccak256("BUYBACK_VAULT");

    function setUp() public {
        stable = new MintableToken("1kUSD", "1K");
        asset = new MintableToken("GOV", "GOV");
        safety = new SafetyStub();
        psm = new PSMStub(stable, asset);

        vault = new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    // --- Constructor guards ---

    function testConstructorZeroStableReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(0),
            address(asset),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroAssetReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(0),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroDaoReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            address(0),
            address(safety),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroSafetyReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(0),
            address(psm),
            MODULE_ID
        );
    }

    function testConstructorZeroPsmReverts() public {
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(safety),
            address(0),
            MODULE_ID
        );
    }

    // --- Helpers ---

    function _fundStableAsDao(uint256 amount) internal {
        stable.mint(dao, amount);
        vm.startPrank(dao);
        stable.approve(address(vault), amount);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    // --- Access & Pause: Stage A ---

    function testFundStableOnlyDaoCanCall() public {
        uint256 amount = 1e18;
        stable.mint(user, amount);

        vm.startPrank(user);
        stable.approve(address(vault), amount);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    function testFundStableEmitsEvent() public {
        uint256 amount = 5e18;
        stable.mint(dao, amount);

        vm.startPrank(dao);
        stable.approve(address(vault), amount);

        // Wir prüfen Signatur + from (dao), ignorieren amount im Daten-Payload
        vm.expectEmit(true, true, false, false);
        emit StableFunded(dao, amount);

        vault.fundStable(amount);
        vm.stopPrank();
    }



    function testFundStableRevertsWhenPaused() public {
        uint256 amount = 1e18;
        stable.mint(dao, amount);

        vm.startPrank(dao);
        stable.approve(address(vault), amount);
        safety.setPaused(true);
        vm.expectRevert(BuybackVault.PAUSED.selector);
        vault.fundStable(amount);
        vm.stopPrank();
    }

    function testWithdrawStableOnlyDao() public {
        _fundStableAsDao(5e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.withdrawStable(user, 1e18);
    }

    function testWithdrawStableZeroAddressReverts() public {
        _fundStableAsDao(5e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawStable(address(0), 1e18);
    }
    function testWithdrawStableEmitsEvent() public {
        uint256 amount = 4e18;
        stable.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit StableWithdrawn(user, amount);

        vault.withdrawStable(user, amount);
    }


    function testWithdrawAssetOnlyDao() public {
        asset.mint(address(vault), 10e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.withdrawAsset(user, 1e18);
    }

    function testWithdrawAssetZeroAddressReverts() public {
        asset.mint(address(vault), 10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.withdrawAsset(address(0), 1e18);
    }
    function testWithdrawAssetEmitsEvent() public {
        uint256 amount = 7e18;
        asset.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit AssetWithdrawn(user, amount);

        vault.withdrawAsset(user, amount);
    }


    // --- Stage B: PSM-basierter Buyback ---

    function testExecuteBuybackOnlyDaoCanCall() public {
        _fundStableAsDao(10e18);

        vm.prank(user);
        vm.expectRevert(BuybackVault.NOT_DAO.selector);
        vault.executeBuybackPSM(5e18, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackRevertsWhenPaused() public {
        _fundStableAsDao(10e18);
        safety.setPaused(true);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.PAUSED.selector);
        vault.executeBuybackPSM(5e18, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackZeroRecipientReverts() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.executeBuybackPSM(5e18, address(0), 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackZeroAmountReverts() public {
        _fundStableAsDao(10e18);

        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_AMOUNT.selector);
        vault.executeBuybackPSM(0, user, 0, block.timestamp + 1 days);
    }

    function testExecuteBuybackTransfersStableAndMintsAsset() public {
        _fundStableAsDao(10e18);

        uint256 amount1k = 4e18;
        uint256 vaultStableBefore = stable.balanceOf(address(vault));
        uint256 userAssetBefore = asset.balanceOf(user);
        uint256 psmStableBefore = stable.balanceOf(address(psm));

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
            stable.balanceOf(address(psm)),
            psmStableBefore + amount1k,
            "PSM stable balance mismatch"
        );
        assertEq(
            asset.balanceOf(user) - userAssetBefore,
            amount1k,
            "user asset balance mismatch"
        );
    }
    function testExecuteBuybackEmitsEvent() public {
        uint256 amount = 10e18;
        stable.mint(address(vault), amount);

        vm.prank(dao);
        // Wir prüfen Signatur + Empfänger, ignorieren assetOut im Daten-Payload
        vm.expectEmit(true, true, false, false);
        emit BuybackExecuted(user, amount, 0);

        vault.executeBuyback(user, amount, 0, block.timestamp + 1 days);
    }




    // --- View-Helper ---


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

    function testBalanceViewsReflectHoldings() public {
        stable.mint(address(vault), 11e18);
        asset.mint(address(vault), 22e18);

        assertEq(vault.stableBalance(), 11e18, "stableBalance mismatch");
        assertEq(vault.assetBalance(), 22e18, "assetBalance mismatch");
    }

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


    // --- Phase B: Oracle health gate telemetry tests ---

    function _configureOracleGate(address module, bool enforced) internal {
        vm.prank(dao);
        vault.setOracleHealthGateConfig(module, enforced);
    }

    function _fundAndPrepareOracleGate(uint256 amount, address module, bool enforced) internal {
        _fundStableAsDao(amount);
        _configureOracleGate(module, enforced);
    }

    function testSetOracleHealthGateConfig_EnforcedWithZeroModuleReverts() public {
        vm.prank(dao);
        vm.expectRevert(BuybackVault.ZERO_ADDRESS.selector);
        vault.setOracleHealthGateConfig(address(0), true);
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

}
