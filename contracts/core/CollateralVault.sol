// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVault} from "../interfaces/IVault.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title CollateralVault — collateral custody with accounting
/// @notice Holds external ERC-20 assets deposited via PSM. Tracks balances per asset.
///         Only authorized callers (e.g. PSM) may call deposit/withdraw.
contract CollateralVault is IVault {
    using SafeERC20 for IERC20;
    // --- Module IDs ---
    bytes32 public constant MODULE_ID = keccak256("VAULT");

    // --- Dependencies ---
    ISafetyAutomata public immutable safety;
    IParameterRegistry public registry; // updatable via admin

    // --- Admin ---
    address public admin; // Timelock placeholder

    // --- Supported Assets ---
    mapping(address => bool) private _isSupported;

    // --- Accounting ---
    mapping(address => uint256) private _balances;

    // --- Authorized callers (e.g. PSM) ---
    mapping(address => bool) public authorizedCallers;

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event AssetSupportSet(address indexed asset, bool supported);

    // Mirrors intended runtime events (no logic here)
    event Deposit(address indexed asset, address indexed from, uint256 amount);
    event Withdraw(address indexed asset, address indexed to, uint256 amount, bytes32 reason);

    event AuthorizedCallerSet(address indexed caller, bool enabled);

    // --- Errors ---
    error ACCESS_DENIED();
    error PAUSED();
    error ZERO_ADDRESS();
    error ASSET_NOT_SUPPORTED();
    error NOT_AUTHORIZED();
    error INSUFFICIENT_VAULT_BALANCE();

    // --- Ctor ---
    constructor(address _admin, ISafetyAutomata _safety, IParameterRegistry _registry) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        if (address(_safety) == address(0)) revert ZERO_ADDRESS();
        if (address(_registry) == address(0)) revert ZERO_ADDRESS();

        admin = _admin;
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

    modifier onlySupported(address asset) {
        if (!_isSupported[asset]) revert ASSET_NOT_SUPPORTED();
        _;
    }

    modifier onlyAuthorized() {
        if (!authorizedCallers[msg.sender] && msg.sender != admin) revert NOT_AUTHORIZED();
        _;
    }

    // --- Admin: roles/config ---
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

    function setAssetSupported(address asset, bool supported) external onlyAdmin {
        if (asset == address(0)) revert ZERO_ADDRESS();
        _isSupported[asset] = supported;
        emit AssetSupportSet(asset, supported);
    }

    function setAuthorizedCaller(address caller, bool enabled) external onlyAdmin {
        if (caller == address(0)) revert ZERO_ADDRESS();
        authorizedCallers[caller] = enabled;
        emit AuthorizedCallerSet(caller, enabled);
    }

    // --- IVault: deposit/withdraw ---

    /// @notice Record a deposit. Tokens must already have been transferred to this vault.
    function deposit(address asset, address from, uint256 amount)
        external
        override
        notPaused
        onlySupported(asset)
        onlyAuthorized
    {
        _balances[asset] += amount;
        emit Deposit(asset, from, amount);
    }

    /// @notice Withdraw tokens from the vault to a recipient.
    function withdraw(address asset, address to, uint256 amount, bytes32 reason)
        external
        override
        notPaused
        onlySupported(asset)
        onlyAuthorized
    {
        if (_balances[asset] < amount) revert INSUFFICIENT_VAULT_BALANCE();
        _balances[asset] -= amount;
        IERC20(asset).safeTransfer(to, amount);
        emit Withdraw(asset, to, amount, reason);
    }

    // --- Views ---
    function balanceOf(address asset)
        external
        view
        override
        returns (uint256)
    {
        return _balances[asset];
    }

    function isAssetSupported(address asset) external view override returns (bool) {
        return _isSupported[asset];
    }

    /// @notice Batch check for UIs/SDKs without on-chain mapping iteration.
    function areAssetsSupported(address[] calldata assets)
        external
        view
        returns (bool[] memory out)
    {
        uint256 n = assets.length;
        out = new bool[](n);
        for (uint256 i = 0; i < n; i++) {
            out[i] = _isSupported[assets[i]];
        }
    }
}
