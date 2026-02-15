// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BuybackVault, IPegStabilityModuleLike} from "../../contracts/core/BuybackVault.sol";

// --- Inline stubs (renamed to avoid collision with BuybackVault.t.sol) ---

contract InvMintableToken is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}
    function mint(address to, uint256 amount) external { _mint(to, amount); }
}

contract InvSafetyStub {
    bool public paused;
    function setPaused(bool value) external { paused = value; }
    function isPaused(bytes32) external view returns (bool) { return paused; }
}

contract InvPSMStub is IPegStabilityModuleLike {
    InvMintableToken public immutable stable;
    InvMintableToken public immutable asset;

    constructor(InvMintableToken _stable, InvMintableToken _asset) {
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
        stable.transferFrom(msg.sender, address(this), amountIn1k);
        amountOut = amountIn1k; // 1:1 swap
        require(amountOut >= minOut, "PSMStub: slippage");
        asset.mint(recipient, amountOut);
    }
}

contract InvOracleHealthStub {
    bool public healthy;
    function setHealthy(bool value) external { healthy = value; }
    function isHealthy() external view returns (bool) { return healthy; }
}

// --- Handler ---

/// @title BuybackVaultHandler
/// @notice Stateful fuzzing handler for BuybackVault. Exercises funding,
///         withdrawal, buyback execution, time warps, pause toggle, and
///         per-op cap reconfiguration.
contract BuybackVaultHandler is Test {
    BuybackVault public vault;
    InvMintableToken public stable;
    InvMintableToken public asset;
    InvSafetyStub public safety;
    address public dao;
    address public recipient;

    // Ghost variables for invariant verification
    uint256 public ghost_totalFunded;
    uint256 public ghost_totalWithdrawn;
    uint256 public ghost_totalBuybacksSpent;
    uint256 public ghost_buybackCallCount;

    constructor(
        BuybackVault _vault,
        InvMintableToken _stable,
        InvMintableToken _asset,
        InvSafetyStub _safety,
        address _dao,
        address _recipient
    ) {
        vault = _vault;
        stable = _stable;
        asset = _asset;
        safety = _safety;
        dao = _dao;
        recipient = _recipient;
    }

    /// @notice Fund the vault with stable tokens.
    function fundStable(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000e18);
        stable.mint(dao, amount);
        vm.startPrank(dao);
        stable.approve(address(vault), amount);
        vault.fundStable(amount);
        vm.stopPrank();
        ghost_totalFunded += amount;
    }

    /// @notice Withdraw stable from vault.
    function withdrawStable(uint256 amount) public {
        uint256 bal = stable.balanceOf(address(vault));
        if (bal == 0) return;
        amount = bound(amount, 1, bal);
        vm.prank(dao);
        vault.withdrawStable(recipient, amount);
        ghost_totalWithdrawn += amount;
    }

    /// @notice Execute a buyback, bounded by per-op and window caps.
    function executeBuyback(uint256 amount) public {
        // Skip if paused
        if (safety.paused()) return;

        uint256 bal = stable.balanceOf(address(vault));
        if (bal == 0) return;

        // Respect per-op cap
        uint16 opCapBps = vault.maxBuybackSharePerOpBps();
        uint256 maxOp = (opCapBps == 0) ? bal : (bal * uint256(opCapBps)) / 10_000;
        if (maxOp == 0) return;
        amount = bound(amount, 1, maxOp);

        // Respect window cap
        uint16 winCapBps = vault.maxBuybackSharePerWindowBps();
        uint64 winDur = vault.buybackWindowDuration();
        if (winDur > 0 && winCapBps > 0) {
            uint128 accum = vault.buybackWindowAccumulatedBps();
            if (accum >= winCapBps) return; // window is full

            // Check if window will reset (use same logic as contract)
            uint64 start = vault.buybackWindowStart();
            bool willReset = (start == 0 || block.timestamp >= uint256(start) + uint256(winDur));

            if (!willReset) {
                uint256 basis = vault.buybackWindowStartStableBalance();
                if (basis > 0) {
                    uint256 remainBps = uint256(winCapBps) - uint256(accum);
                    uint256 maxWin = (basis * remainBps) / 10_000;
                    if (maxWin == 0) return;
                    if (amount > maxWin) amount = maxWin;
                }
            }
            // If willReset, the contract will snapshot current balance and reset accum
        }

        vm.prank(dao);
        try vault.executeBuybackPSM(amount, recipient, 0, block.timestamp + 1 days) {
            ghost_totalBuybacksSpent += amount;
            ghost_buybackCallCount += 1;
        } catch {
            // Cap enforcement or other guard triggered — acceptable
        }
    }

    /// @notice Advance time to exercise window resets.
    function warpWindow(uint256 seconds_) public {
        uint64 dur = vault.buybackWindowDuration();
        uint256 maxWarp = (dur > 0) ? uint256(dur) * 2 : 1 days;
        seconds_ = bound(seconds_, 1, maxWarp);
        vm.warp(block.timestamp + seconds_);
    }

    /// @notice Toggle the pause state.
    function togglePause() public {
        bool current = safety.paused();
        safety.setPaused(!current);
    }

    /// @notice Reconfigure the per-op cap.
    function reconfigureOpCap(uint16 newCapBps) public {
        newCapBps = uint16(bound(uint256(newCapBps), 0, 10_000));
        vm.prank(dao);
        vault.setMaxBuybackSharePerOpBps(newCapBps);
    }
}

// --- Invariant Test ---

/// @title BuybackVault_Invariant
/// @notice Foundry invariant test suite for BuybackVault.
///         Verifies rolling window cap, per-op cap, stable balance accounting,
///         and configuration bounds under arbitrary operation sequences.
contract BuybackVault_Invariant is Test {
    InvMintableToken internal stable;
    InvMintableToken internal asset;
    InvSafetyStub internal safety;
    InvPSMStub internal psm;
    InvOracleHealthStub internal oracleHealth;
    BuybackVault internal vault;
    BuybackVaultHandler internal handler;

    address internal dao = address(0xDA0);
    address internal recipient = address(0xBEEF);
    bytes32 internal constant MODULE_ID = keccak256("BUYBACK_VAULT");

    function setUp() public {
        vm.warp(1_700_000_000);

        stable = new InvMintableToken("1kUSD", "1K");
        asset = new InvMintableToken("GOV", "GOV");
        safety = new InvSafetyStub();
        psm = new InvPSMStub(stable, asset);
        oracleHealth = new InvOracleHealthStub();
        oracleHealth.setHealthy(true);

        vault = new BuybackVault(
            address(stable),
            address(asset),
            dao,
            address(safety),
            address(psm),
            MODULE_ID
        );

        // Configure caps
        vm.startPrank(dao);
        vault.setMaxBuybackSharePerOpBps(5000); // 50%
        vault.setBuybackWindowConfig(3600, 2000); // 1h window, 20% cap
        vault.setOracleHealthGateConfig(address(oracleHealth), true);
        vault.setStrategy(0, address(asset), 10_000, true);
        vault.setStrategiesEnforced(true);
        vm.stopPrank();

        handler = new BuybackVaultHandler(
            vault, stable, asset, safety, dao, recipient
        );

        targetContract(address(handler));
    }

    /// @notice Window accumulated BPS never exceeds the configured window cap.
    function invariant_windowAccumulatedBpsNeverExceedsCap() public view {
        uint16 capBps = vault.maxBuybackSharePerWindowBps();
        uint128 accum = vault.buybackWindowAccumulatedBps();
        assertLe(uint256(accum), uint256(capBps),
            "INV: window accumulated BPS exceeds cap");
    }

    /// @notice Stable balance equals ghost: funded - withdrawn - buybacks.
    function invariant_stableBalanceAccounting() public view {
        uint256 bal = stable.balanceOf(address(vault));
        uint256 expected = handler.ghost_totalFunded()
            - handler.ghost_totalWithdrawn()
            - handler.ghost_totalBuybacksSpent();
        assertEq(bal, expected,
            "INV: stable balance != funded - withdrawn - buybacks");
    }

    /// @notice Total outflow never exceeds total inflow.
    function invariant_totalOutflowBounded() public view {
        assertGe(
            handler.ghost_totalFunded(),
            handler.ghost_totalWithdrawn() + handler.ghost_totalBuybacksSpent(),
            "INV: outflow exceeds inflow"
        );
    }

    /// @notice Per-op cap BPS stays in valid range [0, 10_000].
    function invariant_perOpCapBounded() public view {
        assertLe(uint256(vault.maxBuybackSharePerOpBps()), 10_000,
            "INV: per-op cap BPS > 10_000");
    }

    /// @notice Window cap BPS stays in valid range [0, 10_000].
    function invariant_windowCapBounded() public view {
        assertLe(uint256(vault.maxBuybackSharePerWindowBps()), 10_000,
            "INV: window cap BPS > 10_000");
    }
}
