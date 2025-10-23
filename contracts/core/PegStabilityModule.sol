// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IPSM} from "../interfaces/IPSM.sol";
import {I1kUSD} from "../interfaces/I1kUSD.sol";
import {IVault} from "../interfaces/IVault.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title PegStabilityModule — minimal skeleton (+ token whitelist & dummy quotes)
/// @notice DEV40: Admin/Registry/Guards present; swaps remain NOT_IMPLEMENTED.
///         New: PSM-side whitelist for allowed stable assets + quotes returning (gross=amountIn, fee=0, net=amountIn).
///         No economics/transfers/mint/burn in this version. Compile-only and API-stable.
contract PegStabilityModule is IPSM {
    // --- Modules/IDs ---
    bytes32 public constant MODULE_ID = keccak256("PSM");

    // --- Dependencies (immutable where possible) ---
    I1kUSD public immutable token1k;
    IVault public immutable vault;
    ISafetyAutomata public immutable safety;
    IParameterRegistry public registry; // updatable

    // --- Admin ---
    address public admin;

    // --- Supported tokens (PSM whitelist; separate from Vault support) ---
    mapping(address => bool) private _isSupportedToken;

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event SupportedTokenSet(address indexed asset, bool supported);

    // Runtime swap events (for later real implementation)
    event SwapTo1kUSD(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 fee, uint256 minted, uint256 ts);
    event SwapFrom1kUSD(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 fee, uint256 paidOut, uint256 ts);

    // --- Errors ---
    error ACCESS_DENIED();
    error PAUSED();
    error DEADLINE_EXPIRED();
    error NOT_IMPLEMENTED();
    error ZERO_ADDRESS();
    error UNSUPPORTED_ASSET();

    constructor(
        address _admin,
        I1kUSD _token1k,
        IVault _vault,
        ISafetyAutomata _safety,
        IParameterRegistry _registry
    ) {
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

    modifier onlySupported(address asset) {
        if (!_isSupportedToken[asset]) revert UNSUPPORTED_ASSET();
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

    function setSupportedToken(address asset, bool supported) external onlyAdmin {
        if (asset == address(0)) revert ZERO_ADDRESS();
        _isSupportedToken[asset] = supported;
        emit SupportedTokenSet(asset, supported);
    }

    function isSupportedToken(address asset) external view returns (bool) {
        return _isSupportedToken[asset];
    }

    // --- IPSM: Swaps (stubs; still not implemented) ---
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
        onlySupported(tokenIn)
        returns (uint256 amountOut)
    {
        tokenIn; amountIn; to; minOut;
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
        onlySupported(tokenOut)
        returns (uint256 amountOut)
    {
        tokenOut; amountIn; to; minOut;
        revert NOT_IMPLEMENTED();
    }

    // --- IPSM: Quotes (dummy pass-through; no fee/slippage) ---
    function quoteTo1kUSD(address tokenIn, uint256 amountIn)
        external
        view
        override
        onlySupported(tokenIn)
        returns (uint256 grossOut, uint256 fee, uint256 netOut)
    {
        // DEV40: provisional — 1:1, zero fee; allows dApp/SDK to integrate.
        grossOut = amountIn;
        fee = 0;
        netOut = amountIn;
    }

    function quoteFrom1kUSD(address tokenOut, uint256 amountIn)
        external
        view
        override
        onlySupported(tokenOut)
        returns (uint256 grossOut, uint256 fee, uint256 netOut)
    {
        // DEV40: provisional — 1:1, zero fee.
        grossOut = amountIn;
        fee = 0;
        netOut = amountIn;
    }
}
