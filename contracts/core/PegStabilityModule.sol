// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IPSM} from "../interfaces/IPSM.sol";
import {I1kUSD} from "../interfaces/I1kUSD.sol";
import {IVault} from "../interfaces/IVault.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title PegStabilityModule — minimal skeleton
/// @notice DEV32: only function signatures, events, and safety/param wiring.
///         No pricing, no mint/burn, no transfers. All paths revert NOT_IMPLEMENTED.
contract PegStabilityModule is IPSM {
    // --- Modules/IDs ---
    bytes32 public constant MODULE_ID = keccak256("PSM");

    // --- Dependencies (immutable where possible) ---
    I1kUSD public immutable token1k;         // 1kUSD token
    IVault public immutable vault;           // Collateral vault
    ISafetyAutomata public immutable safety; // Safety/pause/caps/rate-limits
    IParameterRegistry public registry;      // Mutable via admin (Timelock later)

    // --- Admin ---
    address public admin; // expected to be Timelock later

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);

    // Re-emit core swap events (final impl will emit with values)
    event SwapTo1kUSD(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 fee, uint256 minted, uint256 ts);
    event SwapFrom1kUSD(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 fee, uint256 paidOut, uint256 ts);

    // --- Errors ---
    error ACCESS_DENIED();
    error PAUSED();
    error DEADLINE_EXPIRED();
    error NOT_IMPLEMENTED();
    error ZERO_ADDRESS();

    // --- Constructor ---
    constructor(address _admin, I1kUSD _token1k, IVault _vault, ISafetyAutomata _safety, IParameterRegistry _registry) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        if (address(_token1k) == address(0)) revert ZERO_ADDRESS();
        if (address(_vault) == address(0)) revert ZERO_ADDRESS();
        if (address(_safety) == address(0)) revert ZERO_ADDRESS();
        if (address(_registry) == address(0)) revert ZERO_ADDRESS();

        admin = _admin;
        token1k = _token1k;
        vault = _vault;
        safety = _safety;
        registry = _registry;

        emit AdminChanged(address(0), _admin);
        emit RegistryUpdated(address(0), address(_registry));
    }

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(MODULE_ID)) revert PAUSED();
        _;
    }

    modifier checkDeadline(uint256 deadline) {
        if (deadline < block.timestamp) revert DEADLINE_EXPIRED();
        _;
    }

    // --- Admin fns (Timelock later) ---
    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZERO_ADDRESS();
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function setRegistry(IParameterRegistry newRegistry) external onlyAdmin {
        if (address(newRegistry) == address(0)) revert ZERO_ADDRESS();
        emit RegistryUpdated(address(registry), address(newRegistry));
        registry = newRegistry;
    }

    // --- IPSM: Swaps (stubs) ---
    function swapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 deadline
    )
        external
        override
        notPaused
        checkDeadline(deadline)
        returns (uint256 amountOut)
    {
        // DEV32: no logic — just compile-safe guard skeleton.
        // Final impl will: pull tokenIn to Vault, compute fee, mint 1kUSD, emit event.
        tokenIn; amountIn; to; minOut; // silence warnings
        revert NOT_IMPLEMENTED();
    }

    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn,
        address to,
        uint256 minOut,
        uint256 deadline
    )
        external
        override
        notPaused
        checkDeadline(deadline)
        returns (uint256 amountOut)
    {
        // DEV32: no logic — just compile-safe guard skeleton.
        // Final impl will: burn 1kUSD, compute payout minus fee, instruct Vault withdraw, emit event.
        tokenOut; amountIn; to; minOut; // silence warnings
        revert NOT_IMPLEMENTED();
    }

    // --- IPSM: Quotes (stubs) ---
    function quoteTo1kUSD(address tokenIn, uint256 amountIn)
        external
        view
        override
        returns (uint256 grossOut, uint256 fee, uint256 netOut)
    {
        tokenIn; amountIn; // DEV32: pricing TBD
        return (0, 0, 0);
    }

    function quoteFrom1kUSD(address tokenOut, uint256 amountIn)
        external
        view
        override
        returns (uint256 grossOut, uint256 fee, uint256 netOut)
    {
        tokenOut; amountIn; // DEV32: pricing TBD
        return (0, 0, 0);
    }
}
