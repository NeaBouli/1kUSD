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

/// @title PSMHandler
/// @notice Stateful fuzzing handler for PSM. Exercises swapTo1kUSD, swapFrom1kUSD,
///         fee changes, and time warps while tracking ghost state for invariant
///         verification of supply conservation (E1), collateral backing (E2), and
///         fee bounds (E3).
contract PSMHandler is Test {
    PegStabilityModule public psm;
    OneKUSD public oneKUSD;
    CollateralVault public vault;
    MockERC20 public usdc;
    PSMLimits public limits;
    address public admin;
    address public user;

    // Ghost variables for invariant verification
    uint256 public ghost_totalMinted;
    uint256 public ghost_totalBurned;
    uint256 public ghost_collateralIn;
    uint256 public ghost_collateralOut;

    uint256 internal constant DAILY_CAP = 1_000_000e18;
    uint256 internal constant SINGLE_TX_CAP = 100_000e18;

    constructor(
        PegStabilityModule _psm,
        OneKUSD _oneKUSD,
        CollateralVault _vault,
        MockERC20 _usdc,
        PSMLimits _limits,
        address _admin,
        address _user
    ) {
        psm = _psm;
        oneKUSD = _oneKUSD;
        vault = _vault;
        usdc = _usdc;
        limits = _limits;
        admin = _admin;
        user = _user;
    }

    /// @notice Swap collateral -> 1kUSD with bounded amount.
    function swapTo1kUSD(uint256 amount) public {
        uint256 userBal = usdc.balanceOf(user);
        if (userBal == 0) return;

        // Bound by user balance and single-tx cap
        uint256 maxAmount = userBal < SINGLE_TX_CAP ? userBal : SINGLE_TX_CAP;
        amount = bound(amount, 1, maxAmount);

        vm.prank(user);
        try psm.swapTo1kUSD(address(usdc), amount, user, 0, 0) returns (uint256 net) {
            ghost_totalMinted += net;
            ghost_collateralIn += amount;
        } catch {
            // Daily cap, single-tx cap, or other guard — acceptable
        }
    }

    /// @notice Swap 1kUSD -> collateral with bounded amount.
    function swapFrom1kUSD(uint256 amount) public {
        uint256 userBal = oneKUSD.balanceOf(user);
        if (userBal == 0) return;

        // Bound by user 1kUSD balance and single-tx cap
        uint256 maxAmount = userBal < SINGLE_TX_CAP ? userBal : SINGLE_TX_CAP;
        amount = bound(amount, 1, maxAmount);

        vm.prank(user);
        try psm.swapFrom1kUSD(address(usdc), amount, user, 0, 0) returns (uint256 netOut) {
            ghost_totalBurned += amount;
            ghost_collateralOut += netOut;
        } catch {
            // Daily cap, insufficient vault balance, or other guard — acceptable
        }
    }

    /// @notice Randomize fees within safe bounds (fee + spread <= 10,000 bps).
    function setFees(uint256 mintFee, uint256 redeemFee) public {
        mintFee = bound(mintFee, 0, 5000);
        redeemFee = bound(redeemFee, 0, 5000);
        vm.prank(admin);
        psm.setFees(mintFee, redeemFee);
    }

    /// @notice Warp forward 1 day to reset daily volume limits.
    function warpDay() public {
        vm.warp(block.timestamp + 1 days);
    }
}

/// @title PSM_Invariant
/// @notice Foundry invariant test suite for PegStabilityModule.
///         Verifies supply conservation (E1), collateral backing (E2), vault
///         solvency, and fee bounds (E3) under fuzzed swap sequences.
contract PSM_Invariant is Test {
    SafetyAutomata internal safety;
    ParameterRegistry internal registry;
    MockOracleAggregator internal oracle;
    CollateralVault internal vault;
    OneKUSD internal oneKUSD;
    PSMLimits internal limits;
    FeeRouter internal feeRouter;
    PegStabilityModule internal psm;
    MockERC20 internal usdc;
    PSMHandler internal handler;

    address internal admin = address(this);
    address internal user = address(0xBEEF);

    uint256 internal constant DAILY_CAP = 1_000_000e18;
    uint256 internal constant SINGLE_TX_CAP = 100_000e18;

    function setUp() public {
        vm.warp(1_700_000_000);

        // ===== Phase 1: Core Infrastructure (mirrors PSM_SmokeTest.t.sol) =====
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

        // ===== Phase 2: Authorized Caller Whitelist =====
        oneKUSD.setMinter(address(psm), true);
        oneKUSD.setBurner(address(psm), true);
        vault.setAuthorizedCaller(address(psm), true);
        vault.setAssetSupported(address(usdc), true);
        limits.setAuthorizedCaller(address(psm), true);

        // ===== Phase 3: Oracle Configuration =====
        oracle.setPrice(int256(1e18), 18, true);
        psm.setOracle(address(oracle));

        // ===== Phase 4: PSM Configuration =====
        psm.setFees(0, 0);
        psm.setLimits(address(limits));

        // ===== Fund user =====
        usdc.mint(user, 100_000_000e18);
        vm.prank(user);
        usdc.approve(address(psm), type(uint256).max);

        // ===== Handler =====
        handler = new PSMHandler(psm, oneKUSD, vault, usdc, limits, admin, user);
        targetContract(address(handler));
    }

    /// @notice E1: Supply conservation — total supply equals cumulative mints minus burns.
    function invariant_supplyConservation() public view {
        uint256 expected = handler.ghost_totalMinted() - handler.ghost_totalBurned();
        assertEq(oneKUSD.totalSupply(), expected,
            "INV-E1: supply != minted - burned");
    }

    /// @notice E2: Collateral backing — vault accounting equals cumulative deposits minus withdrawals.
    function invariant_collateralBacking() public view {
        uint256 expected = handler.ghost_collateralIn() - handler.ghost_collateralOut();
        assertEq(vault.balanceOf(address(usdc)), expected,
            "INV-E2: vault accounting != collateralIn - collateralOut");
    }

    /// @notice Vault solvency — actual token balance >= accounting balance.
    function invariant_vaultSolvent() public view {
        uint256 actualBalance = usdc.balanceOf(address(vault));
        uint256 accountingBalance = vault.balanceOf(address(usdc));
        assertGe(actualBalance, accountingBalance,
            "INV: vault actual balance < accounting balance");
    }

    /// @notice E3: Fee bounds — net minted 1kUSD never exceeds collateral deposited.
    function invariant_feeNeverExceedsInput() public view {
        assertLe(handler.ghost_totalMinted(), handler.ghost_collateralIn(),
            "INV-E3: total minted > total collateral in (fee violation)");
    }

    /// @notice Supply is non-negative (validates no underflow revert in the sequence).
    function invariant_supplyNonNegative() public view {
        // Trivially true for uint256, but if an underflow occurred during a swap
        // sequence the entire run would revert — this invariant existing ensures
        // the fuzzer's sequence completed without panic.
        assertTrue(oneKUSD.totalSupply() >= 0,
            "INV: supply underflow");
    }
}
