// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";
import {FeeRouter} from "../../contracts/core/FeeRouter.sol";
import {MockOracleAggregator} from "./mocks/MockOracleAggregator.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/// @title PSM_EconSim
/// @notice Sprint 3 Task 5: Economic simulation scenarios for audit prep.
///         10 deterministic scenarios covering multi-day fee accrual, depeg stress,
///         bank runs, worst-case parameters, and combined parameter interactions.
///         Each test produces a console.log audit trail for human verification.
contract PSM_EconSim is Test {
    SafetyAutomata internal safety;
    ParameterRegistry internal registry;
    MockOracleAggregator internal oracle;
    CollateralVault internal vault;
    OneKUSD internal oneKUSD;
    PSMLimits internal limits;
    FeeRouter internal feeRouter;
    PegStabilityModule internal psm;
    MockERC20 internal usdc;

    address internal admin = address(this);
    address internal user = address(0xBEEF);

    uint256 internal constant DAILY_CAP = 10_000_000e18;
    uint256 internal constant SINGLE_TX_CAP = 1_000_000e18;

    bytes32 private constant KEY_MINT_SPREAD = keccak256("psm:mintSpreadBps");
    bytes32 private constant KEY_REDEEM_SPREAD = keccak256("psm:redeemSpreadBps");

    function setUp() public {
        vm.warp(1_700_000_000);

        // Phase 1: Core Infrastructure (mirrors PSM_SmokeTest.t.sol)
        safety = new SafetyAutomata(admin, block.timestamp + 365 days);
        registry = new ParameterRegistry(admin);
        oracle = new MockOracleAggregator();
        vault = new CollateralVault(admin, safety, registry);
        oneKUSD = new OneKUSD(admin);
        limits = new PSMLimits(admin, DAILY_CAP, SINGLE_TX_CAP);
        feeRouter = new FeeRouter(admin);
        psm = new PegStabilityModule(
            admin,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );
        usdc = new MockERC20("USDC", "USDC");

        // Phase 2: Authorized Caller Whitelist
        oneKUSD.setMinter(address(psm), true);
        oneKUSD.setBurner(address(psm), true);
        vault.setAuthorizedCaller(address(psm), true);
        vault.setAssetSupported(address(usdc), true);
        limits.setAuthorizedCaller(address(psm), true);

        // Phase 3: Oracle Configuration
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));

        // Phase 4: PSM Configuration
        psm.setFees(0, 0);
        psm.setLimits(address(limits));

        // Fund user
        usdc.mint(user, 100_000_000e18);
        vm.prank(user);
        usdc.approve(address(psm), type(uint256).max);
    }

    // -----------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------

    function _mint(uint256 amount) internal returns (uint256) {
        vm.prank(user);
        return psm.swapTo1kUSD(address(usdc), amount, user, 0, 0);
    }

    function _redeem(uint256 amount) internal returns (uint256) {
        vm.prank(user);
        return psm.swapFrom1kUSD(address(usdc), amount, user, 0, 0);
    }

    function _logMetrics(string memory label) internal view {
        uint256 supply = oneKUSD.totalSupply();
        uint256 vaultBal = vault.balanceOf(address(usdc));
        console.log("---", label, "---");
        console.log("  Supply:     ", supply);
        console.log("  Vault:      ", vaultBal);
        console.log("  User USDC:  ", usdc.balanceOf(user));
        console.log("  User 1kUSD: ", oneKUSD.balanceOf(user));
        if (supply > 0) {
            console.log("  Ratio (bps):", (vaultBal * 10_000) / supply);
        }
    }

    // =================================================================
    // Scenario 1: Fee Accrual Over 30 Days
    // Invariants: E1 (supply conservation), E2 (collateral backing), E7 (rounding)
    // =================================================================

    function testEcon_FeeAccrual_30Days() public {
        psm.setFees(50, 50); // 0.5% mint + 0.5% redeem

        uint256 prevSurplus = 0;
        console.log("=== Scenario 1: Fee Accrual 30 Days (50 bps each side) ===");

        for (uint256 day = 0; day < 30; day++) {
            vm.warp(1_700_000_000 + day * 1 days);

            _mint(100_000e18);

            uint256 userBal = oneKUSD.balanceOf(user);
            _redeem(userBal / 2);

            uint256 supply = oneKUSD.totalSupply();
            uint256 vaultBal = vault.balanceOf(address(usdc));
            uint256 surplus = vaultBal - supply;

            assertGt(vaultBal, supply, "vault must exceed supply (over-collateralized)");
            assertGe(surplus, prevSurplus, "surplus must not decrease");
            prevSurplus = surplus;
        }

        _logMetrics("After 30 days");
        console.log("  Final surplus:", prevSurplus);

        assertGt(vault.balanceOf(address(usdc)), oneKUSD.totalSupply(),
            "final: vault must exceed supply");
    }

    // =================================================================
    // Scenario 2: Oracle Depeg Stress
    // Invariant: E2 (collateral backing holds under price changes)
    // =================================================================

    function testEcon_DepegStress_OracleDrop() public {
        console.log("=== Scenario 2: Oracle Depeg Stress ===");

        // Phase A: Mint at 1:1
        uint256 mintedA = _mint(1_000_000e18);
        assertEq(mintedA, 1_000_000e18, "Phase A: 1:1 mint should be exact");
        _logMetrics("Phase A: 1:1 mint");

        // Phase B: Oracle drops to 0.95
        oracle.setPrice(int256(95e16), 18, true);
        uint256 mintedB = _mint(1_000_000e18);
        assertEq(mintedB, 950_000e18, "Phase B: 0.95 price should yield 950k");
        _logMetrics("Phase B: 0.95 mint");

        // Vault backing check: 2M USDC backing 1.95M 1kUSD
        assertGe(vault.balanceOf(address(usdc)), oneKUSD.totalSupply(),
            "vault must back supply after depeg mint");

        // Phase C: Redeem at 0.95 — inverse math returns full collateral
        uint256 redeemedC = _redeem(950_000e18);
        assertEq(redeemedC, 1_000_000e18, "Phase C: redeem at 0.95 returns full collateral");
        _logMetrics("Phase C: redeem at 0.95");

        // Phase D: Oracle recovers, redeem remaining
        oracle.setPrice(int256(1e18), 18, true);
        uint256 redeemedD = _redeem(1_000_000e18);
        assertEq(redeemedD, 1_000_000e18, "Phase D: redeem at 1:1 returns full collateral");
        _logMetrics("Phase D: recovered, clean exit");

        assertEq(oneKUSD.totalSupply(), 0, "supply should be zero");
        assertEq(vault.balanceOf(address(usdc)), 0, "vault should be zero");
    }

    // =================================================================
    // Scenario 3: Bank Run — Mass Redemption
    // Invariants: E1, E2
    // =================================================================

    function testEcon_BankRun_MassRedemption() public {
        // Raise limits to allow large single-tx for bank-run scenario
        limits.setLimits(20_000_000e18, 10_000_000e18);
        console.log("=== Scenario 3: Bank Run ===");

        uint256 initialUserUsdc = usdc.balanceOf(user);

        uint256 minted = _mint(10_000_000e18);
        _logMetrics("After mass mint (10M)");
        assertEq(minted, 10_000_000e18);

        uint256 redeemed = _redeem(minted);
        _logMetrics("After full redemption");
        assertEq(redeemed, 10_000_000e18);

        // Clean exit verification
        assertEq(oneKUSD.totalSupply(), 0, "supply must be zero");
        assertEq(vault.balanceOf(address(usdc)), 0, "vault accounting must be zero");
        assertEq(usdc.balanceOf(address(vault)), 0, "no stuck collateral in vault");
        assertEq(oneKUSD.balanceOf(user), 0, "user 1kUSD must be zero");
        assertEq(usdc.balanceOf(user), initialUserUsdc, "user USDC fully restored");
    }

    // =================================================================
    // Scenario 4: Worst Case #1 — Zero Fees (10 roundtrips, zero dust)
    // Invariant: E7 (rounding)
    // =================================================================

    function testEcon_WorstCase_ZeroFees() public {
        console.log("=== Scenario 4: Zero Fees - 10 Roundtrips ===");

        uint256 initialUsdc = usdc.balanceOf(user);

        for (uint256 i = 0; i < 10; i++) {
            uint256 amount = (1_000 + i * 100) * 1e18; // 1000e18 to 1900e18
            uint256 minted = _mint(amount);
            assertEq(minted, amount, "mint should be exact at 0 fees");

            uint256 redeemed = _redeem(minted);
            assertEq(redeemed, amount, "redeem should return exact input");
        }

        assertEq(oneKUSD.totalSupply(), 0, "supply must be zero after all roundtrips");
        assertEq(vault.balanceOf(address(usdc)), 0, "vault must be zero");
        assertEq(usdc.balanceOf(user), initialUsdc, "user USDC unchanged");

        console.log("  10 roundtrips complete. Zero dust confirmed.");
    }

    // =================================================================
    // Scenario 5: Worst Case — Max Fees (50% + 50%)
    // Invariants: E1, E2, E3
    // =================================================================

    function testEcon_WorstCase_MaxFees() public {
        psm.setFees(5000, 5000); // 50% each side
        console.log("=== Scenario 5: Max Fees (50%+50%) ===");

        uint256 minted = _mint(1_000_000e18);
        assertEq(minted, 500_000e18, "50% mint fee: net should be 500k");
        _logMetrics("After 50% fee mint");

        uint256 redeemed = _redeem(minted);
        assertEq(redeemed, 250_000e18, "50% redeem fee: net should be 250k");
        _logMetrics("After 50% fee redeem");

        // Verify protocol economics
        assertEq(oneKUSD.totalSupply(), 0, "supply returns to zero");
        assertEq(vault.balanceOf(address(usdc)), 750_000e18,
            "vault retains 750k (75% of input)");

        console.log("  User input:     1,000,000");
        console.log("  User received:  250,000");
        console.log("  Protocol kept:  750,000");
    }

    // =================================================================
    // Scenario 6: Worst Case #2 — Oracle Down
    // =================================================================

    function testEcon_WorstCase_OracleDown() public {
        psm.setFees(50, 50);
        console.log("=== Scenario 6: Oracle Down ===");

        // Establish baseline
        uint256 minted = _mint(100_000e18);
        uint256 snapshotSupply = oneKUSD.totalSupply();
        uint256 snapshotVault = vault.balanceOf(address(usdc));
        _logMetrics("Baseline (before oracle failure)");

        // Oracle goes unhealthy
        oracle.setPrice(int256(1e18), 18, false);

        // Both mint and redeem must revert
        vm.prank(user);
        vm.expectRevert("PSM: oracle not operational");
        psm.swapTo1kUSD(address(usdc), 1_000e18, user, 0, 0);

        vm.prank(user);
        vm.expectRevert("PSM: oracle not operational");
        psm.swapFrom1kUSD(address(usdc), 1_000e18, user, 0, 0);

        // Zero state change
        assertEq(oneKUSD.totalSupply(), snapshotSupply, "supply unchanged during oracle outage");
        assertEq(vault.balanceOf(address(usdc)), snapshotVault, "vault unchanged during oracle outage");
        console.log("  Oracle down: all swaps blocked, zero state change.");

        // Oracle recovers
        oracle.setPrice(int256(1e18), 18, true);
        uint256 redeemed = _redeem(minted);
        assertGt(redeemed, 0, "operations resume after oracle recovery");
        _logMetrics("After oracle recovery");
    }

    // =================================================================
    // Scenario 7: Worst Case #5 — Limits Zero
    // Invariant: E4
    // =================================================================

    function testEcon_WorstCase_LimitsZero() public {
        console.log("=== Scenario 7: Limits Zero ===");

        // Establish baseline
        uint256 minted = _mint(100_000e18);
        uint256 snapshotSupply = oneKUSD.totalSupply();
        uint256 snapshotVault = vault.balanceOf(address(usdc));
        _logMetrics("Baseline");

        // Set limits to zero — halts all swaps
        limits.setLimits(0, 0);

        vm.prank(user);
        vm.expectRevert();
        psm.swapTo1kUSD(address(usdc), 1e18, user, 0, 0);

        vm.prank(user);
        vm.expectRevert();
        psm.swapFrom1kUSD(address(usdc), 1e18, user, 0, 0);

        // Zero state change
        assertEq(oneKUSD.totalSupply(), snapshotSupply, "supply unchanged with zero limits");
        assertEq(vault.balanceOf(address(usdc)), snapshotVault, "vault unchanged with zero limits");
        console.log("  Limits zero: all swaps blocked.");

        // Re-enable limits — recovery
        limits.setLimits(DAILY_CAP, SINGLE_TX_CAP);
        uint256 redeemed = _redeem(minted);
        assertEq(redeemed, 100_000e18, "recovery: full redeem after re-enabling limits");
        _logMetrics("After recovery");
    }

    // =================================================================
    // Scenario 8: Spread + Fee Interaction (additive)
    // Invariant: E3 (fee bounds)
    // =================================================================

    function testEcon_SpreadAndFeeInteraction() public {
        psm.setFees(100, 100); // 1% fee each side
        registry.setUint(KEY_MINT_SPREAD, 50);   // 0.5% mint spread
        registry.setUint(KEY_REDEEM_SPREAD, 50);  // 0.5% redeem spread
        // total = 1.5% each side

        console.log("=== Scenario 8: Fee(100) + Spread(50) = 150 bps ===");

        // Mint 1M: total deduction = 150 bps
        uint256 minted = _mint(1_000_000e18);
        // fee+spread = 1_000_000e18 * 150 / 10000 = 15_000e18
        assertEq(minted, 985_000e18, "mint net = 1M - 1.5%");
        _logMetrics("After mint");

        // Redeem 985k: total deduction = 150 bps
        uint256 redeemed = _redeem(minted);
        // fee+spread = 985_000e18 * 150 / 10000 = 14_775e18
        // net = 985_000e18 - 14_775e18 = 970_225e18
        assertEq(redeemed, 970_225e18, "redeem net = 985k - 1.5%");
        _logMetrics("After redeem");

        // Protocol surplus
        uint256 surplus = vault.balanceOf(address(usdc));
        assertEq(surplus, 29_775e18, "surplus = 1M - 970,225 = 29,775");
        assertEq(oneKUSD.totalSupply(), 0, "supply returns to zero");

        console.log("  Total fee+spread retained:", surplus);
        console.log("  Confirms additive (not multiplicative) deduction.");
    }

    // =================================================================
    // Scenario 9: Daily Cap Exhaustion + Recovery
    // Invariant: E4 (rate limit)
    // =================================================================

    function testEcon_DailyCapExhaustion_Recovery() public {
        // Override limits: 500k daily, 200k single-tx
        limits.setLimits(500_000e18, 200_000e18);
        console.log("=== Scenario 9: Daily Cap Exhaustion ===");

        // Fill daily cap: 200k + 200k + 100k = 500k
        _mint(200_000e18);
        _mint(200_000e18);
        _mint(100_000e18);
        _logMetrics("Daily cap fully used (500k)");

        // Next swap must revert (even 1 wei)
        vm.prank(user);
        vm.expectRevert();
        psm.swapTo1kUSD(address(usdc), 1e18, user, 0, 0);

        // Redeem also counts toward daily volume
        vm.prank(user);
        vm.expectRevert();
        psm.swapFrom1kUSD(address(usdc), 1e18, user, 0, 0);

        console.log("  Cap exhausted: all swaps blocked.");

        // Warp to next day — auto-reset
        vm.warp(block.timestamp + 1 days);

        uint256 redeemed = _redeem(200_000e18);
        assertEq(redeemed, 200_000e18, "next day: redeem succeeds after reset");
        assertEq(limits.dailyVolume(), 200_000e18, "daily volume reflects only today's activity");
        _logMetrics("Next day: recovered");
    }

    // =================================================================
    // Scenario 10: Collateral Surplus — Fee Retention Proof
    // Invariants: E1, E2, E7 (audit proof)
    // =================================================================

    function testEcon_CollateralSurplus_FeeRetention() public {
        psm.setFees(100, 200); // 1% mint, 2% redeem (asymmetric)
        console.log("=== Scenario 10: Collateral Surplus Proof (1% mint, 2% redeem) ===");

        uint256 cumulativeMintFees = 0;
        uint256 cumulativeRedeemSurplus = 0;
        uint256[] memory netMinted = new uint256[](5);

        // Phase A: 5 mints of increasing amounts
        for (uint256 i = 0; i < 5; i++) {
            uint256 amountIn = (i + 1) * 100_000e18; // 100k, 200k, 300k, 400k, 500k
            uint256 net = _mint(amountIn);
            uint256 fee = amountIn - net;
            cumulativeMintFees += fee;
            netMinted[i] = net;
            console.log("  Mint:", amountIn, "-> net:", net);
        }

        // Checkpoint: mint fees are retained as surplus
        uint256 supply = oneKUSD.totalSupply();
        uint256 vaultBal = vault.balanceOf(address(usdc));
        assertEq(vaultBal - supply, cumulativeMintFees,
            "surplus after mints == cumulative mint fees");
        console.log("  Mint-phase surplus:", vaultBal - supply);

        // Phase B: 5 partial redeems (half of each mint's net)
        for (uint256 i = 0; i < 5; i++) {
            uint256 redeemAmount = netMinted[i] / 2;
            uint256 netOut = _redeem(redeemAmount);
            cumulativeRedeemSurplus += (redeemAmount - netOut);
            console.log("  Redeem:", redeemAmount, "-> out:", netOut);
        }

        // Final accounting proof
        uint256 finalSupply = oneKUSD.totalSupply();
        uint256 finalVault = vault.balanceOf(address(usdc));
        uint256 totalSurplus = finalVault - finalSupply;

        assertEq(totalSurplus, cumulativeMintFees + cumulativeRedeemSurplus,
            "total surplus == mint fees + redeem surplus");

        assertGt(finalVault * 10_000 / finalSupply, 10_000,
            "collateral ratio > 100%");

        console.log("=== AUDIT SUMMARY ===");
        console.log("  Vault collateral:     ", finalVault);
        console.log("  Outstanding supply:   ", finalSupply);
        console.log("  Collateral surplus:   ", totalSurplus);
        console.log("    From mint fees:     ", cumulativeMintFees);
        console.log("    From redeem fees:   ", cumulativeRedeemSurplus);
        console.log("  Collateral ratio bps: ", (finalVault * 10_000) / finalSupply);
    }
}
