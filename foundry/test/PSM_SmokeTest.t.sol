// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";
import {FeeRouter} from "../../contracts/core/FeeRouter.sol";
import {MockOracleAggregator} from "./mocks/MockOracleAggregator.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

/// @title PSM_SmokeTest
/// @notice Phase 7 post-deployment verification: state checks, full roundtrip
///         smoke test, and negative tests using ALL real contracts.
///         Follows DEPLOYMENT_CHECKLIST_v051.md Phases 1-5 for setUp wiring.
contract PSM_SmokeTest is Test {
    // --- Real contracts (no MockCollateralVault) ---
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
    address internal unauthorizedCaller = address(0xDEAD);

    uint256 internal constant DAILY_CAP = 1_000_000e18;
    uint256 internal constant SINGLE_TX_CAP = 100_000e18;
    uint256 internal constant SMOKE_AMOUNT = 100e18;

    function setUp() public {
        vm.warp(1_700_000_000);

        // ===== Phase 1: Core Infrastructure Deploy (exact checklist order) =====
        // Step 1: SafetyAutomata
        safety = new SafetyAutomata(admin, block.timestamp + 365 days);

        // Step 2: ParameterRegistry
        registry = new ParameterRegistry(admin);

        // Step 3: OracleAggregator (MockOracleAggregator — established test pattern)
        oracle = new MockOracleAggregator();

        // Step 4: CollateralVault (REAL — not MockCollateralVault)
        vault = new CollateralVault(admin, safety, registry);

        // Step 5: OneKUSD
        oneKUSD = new OneKUSD(admin);

        // Step 6: PSMLimits
        limits = new PSMLimits(admin, DAILY_CAP, SINGLE_TX_CAP);

        // Step 7: FeeRouter
        feeRouter = new FeeRouter(admin);

        // Step 8: PegStabilityModule
        psm = new PegStabilityModule(
            admin,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );

        // Collateral token
        usdc = new MockERC20("USDC", "USDC");

        // ===== Phase 2: Authorized Caller Whitelist =====
        // 2.1 OneKUSD mint/burn roles
        oneKUSD.setMinter(address(psm), true);
        oneKUSD.setBurner(address(psm), true);

        // 2.2 CollateralVault caller + asset auth
        vault.setAuthorizedCaller(address(psm), true);
        vault.setAssetSupported(address(usdc), true);

        // 2.3 PSMLimits caller auth
        limits.setAuthorizedCaller(address(psm), true);

        // 2.4 FeeRouter — PSM uses IFeeRouterV2 (not v1); feeRouter stays address(0) on PSM per v0.51.x

        // ===== Phase 3: Oracle Configuration =====
        // 3.1 Wire oracle to PSM
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));

        // ===== Phase 4: PSM Configuration =====
        // 4.1 Fees (0 bps for clean roundtrip)
        psm.setFees(0, 0);

        // 4.2 Limits
        psm.setLimits(address(limits));

        // 4.3 FeeRouter not wired — IFeeRouterV2 not implemented yet

        // ===== Phase 5: Safety-Automata =====
        // Admin already has roles — no extra guardian wiring needed

        // ===== Fund user for tests =====
        usdc.mint(user, 10_000e18);
        vm.prank(user);
        usdc.approve(address(psm), type(uint256).max);
    }

    // -----------------------------------------------------------------
    // Phase 7.1: State Checks — 10 post-deployment validations
    // -----------------------------------------------------------------

    /// @notice Phase 7.1 — All 10 state checks from the deployment checklist.
    ///         Any failure = system is misconfigured.
    function testPhase7_1_StateChecks() public view {
        // 1. psm.oracle() != address(0) — oracle wired
        assertTrue(address(psm.oracle()) != address(0), "7.1.1: oracle not wired");

        // 2. oracle.isOperational() == true — oracle not paused
        assertTrue(oracle.isOperational(), "7.1.2: oracle not operational");

        // 3. oneKUSD.isMinter(psm) == true — PSM can mint
        assertTrue(oneKUSD.isMinter(address(psm)), "7.1.3: PSM not minter");

        // 4. oneKUSD.isBurner(psm) == true — PSM can burn
        assertTrue(oneKUSD.isBurner(address(psm)), "7.1.4: PSM not burner");

        // 5. vault.isAssetSupported(token) == true — collateral accepted
        assertTrue(vault.isAssetSupported(address(usdc)), "7.1.5: USDC not supported");

        // 6. vault.authorizedCallers(psm) == true — PSM can deposit/withdraw
        assertTrue(vault.authorizedCallers(address(psm)), "7.1.6: PSM not authorized on vault");

        // 7. limits.authorizedCallers(psm) == true — PSM can update limits
        assertTrue(limits.authorizedCallers(address(psm)), "7.1.7: PSM not authorized on limits");

        // 8. safetyAutomata.isPaused(keccak256("PSM")) == false — PSM not paused
        assertFalse(safety.isPaused(keccak256("PSM")), "7.1.8: PSM is paused");

        // 9. safetyAutomata.isPaused(keccak256("VAULT")) == false — vault not paused
        assertFalse(safety.isPaused(keccak256("VAULT")), "7.1.9: VAULT is paused");

        // 10. safetyAutomata.isPaused(keccak256("ORACLE")) == false — oracle not paused
        assertFalse(safety.isPaused(keccak256("ORACLE")), "7.1.10: ORACLE is paused");
    }

    // -----------------------------------------------------------------
    // Phase 7.2: Full Roundtrip Smoke Test
    // -----------------------------------------------------------------

    /// @notice Phase 7.2 — Full roundtrip: collateral -> 1kUSD -> collateral.
    ///         At 0% fees and 1:1 price, roundtrip must be lossless.
    function testPhase7_2_FullRoundtrip() public {
        uint256 userCollBefore = usdc.balanceOf(user);
        uint256 user1kBefore = oneKUSD.balanceOf(user);
        uint256 supplyBefore = oneKUSD.totalSupply();
        uint256 vaultBalBefore = vault.balanceOf(address(usdc));

        // Step 1: user approval done in setUp

        // Step 2: Swap collateral -> 1kUSD
        vm.prank(user);
        uint256 minted = psm.swapTo1kUSD(
            address(usdc),
            SMOKE_AMOUNT,
            user,
            0,
            block.timestamp + 300
        );

        // Mid-roundtrip invariants
        assertEq(oneKUSD.totalSupply(), supplyBefore + minted, "supply did not increase by minted");
        assertEq(oneKUSD.balanceOf(user), user1kBefore + minted, "user 1kUSD delta mismatch");
        assertEq(vault.balanceOf(address(usdc)), vaultBalBefore + SMOKE_AMOUNT, "vault collateral delta");
        assertEq(usdc.balanceOf(user), userCollBefore - SMOKE_AMOUNT, "user collateral not debited");

        // Step 3: Approve 1kUSD for PSM (production-like, even though burn doesn't require allowance)
        vm.prank(user);
        oneKUSD.approve(address(psm), minted);

        // Step 4: Swap 1kUSD -> collateral
        vm.prank(user);
        uint256 redeemed = psm.swapFrom1kUSD(
            address(usdc),
            minted,
            user,
            0,
            block.timestamp + 300
        );

        // Step 5: Verify full roundtrip
        assertEq(oneKUSD.totalSupply(), supplyBefore, "supply did not roundtrip");
        assertEq(oneKUSD.balanceOf(user), user1kBefore, "user 1kUSD did not roundtrip");
        assertEq(usdc.balanceOf(user), userCollBefore, "user collateral did not roundtrip");
        assertEq(vault.balanceOf(address(usdc)), vaultBalBefore, "vault collateral did not roundtrip");

        // At 1:1 and 0 fees: amounts must be exact
        assertEq(minted, SMOKE_AMOUNT, "minted amount should equal input at 1:1");
        assertEq(redeemed, SMOKE_AMOUNT, "redeem amount should equal original");
    }

    // -----------------------------------------------------------------
    // Phase 7.3: Negative Tests
    // -----------------------------------------------------------------

    /// @notice 7.3.1: Swap with unsupported collateral reverts ASSET_NOT_SUPPORTED at vault.
    function testNeg_UnsupportedToken_Reverts() public {
        MockERC20 badToken = new MockERC20("BAD", "BAD");
        badToken.mint(user, 100e18);
        vm.prank(user);
        badToken.approve(address(psm), type(uint256).max);

        vm.prank(user);
        vm.expectRevert(CollateralVault.ASSET_NOT_SUPPORTED.selector);
        psm.swapTo1kUSD(address(badToken), 100e18, user, 0, 0);
    }

    /// @notice 7.3.2: Swap with expired deadline reverts PSM_DEADLINE_EXPIRED.
    function testNeg_ExpiredDeadline_Reverts() public {
        uint256 pastDeadline = block.timestamp - 1;

        vm.prank(user);
        vm.expectRevert(PegStabilityModule.PSM_DEADLINE_EXPIRED.selector);
        psm.swapTo1kUSD(address(usdc), 100e18, user, 0, pastDeadline);
    }

    /// @notice 7.3.3: Swap when oracle is not operational reverts.
    function testNeg_OraclePaused_Reverts() public {
        oracle.setPrice(int256(1e18), 18, false);

        vm.prank(user);
        vm.expectRevert("PSM: oracle not operational");
        psm.swapTo1kUSD(address(usdc), 100e18, user, 0, 0);
    }

    /// @notice 7.3.4: Direct vault.deposit by unauthorized caller reverts NOT_AUTHORIZED.
    function testNeg_DirectVaultAccess_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(CollateralVault.NOT_AUTHORIZED.selector);
        vault.deposit(address(usdc), unauthorizedCaller, 1e18);
    }

    /// @notice 7.3.5: Direct limits.checkAndUpdate by unauthorized caller reverts.
    function testNeg_DirectLimitsAccess_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(PSMLimits.NOT_AUTHORIZED.selector);
        limits.checkAndUpdate(1e18);
    }

    /// @notice 7.3.6: Direct feeRouter.routeToTreasury by unauthorized caller reverts.
    function testNeg_DirectFeeRouterAccess_Reverts() public {
        vm.prank(unauthorizedCaller);
        vm.expectRevert(FeeRouter.NotAuthorized.selector);
        feeRouter.routeToTreasury(address(usdc), address(0xBEEF), 1e18, bytes32("TEST"));
    }

    /// @notice 7.3.7: setFees with mintFee > 10,000 reverts.
    function testNeg_FeeTooHigh_Reverts() public {
        vm.expectRevert("PSM: mintFee too high");
        psm.setFees(10_001, 0);
    }
}
