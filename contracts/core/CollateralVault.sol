// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IVault} from "../interfaces/IVault.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../interfaces/IParameterRegistry.sol";

/// @title CollateralVault — minimal skeleton (+ batch getter)
/// @notice DEV41: Admin/Wiring/Guards + Events as before. New: `areAssetsSupported(...)`.
///         No asset transfers/accounting; balanceOf() stays a dummy (0).
contract CollateralVault is IVault {
    // --- Module IDs ---
    bytes32 public constant MODULE_ID = keccak256("VAULT");

    // --- Dependencies ---
    ISafetyAutomata public immutable safety;
    IParameterRegistry public registry; // updatable via admin

    // --- Admin ---
    address public admin; // Timelock placeholder

    // --- Supported Assets (toggle only; no amounts logic) ---
    mapping(address => bool) private _isSupported;

    // --- Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event RegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    event AssetSupportSet(address indexed asset, bool supported);

    // Mirrors intended runtime events (no logic here)
    event Deposit(address indexed asset, address indexed from, uint256 amount);
    event Withdraw(address indexed asset, address indexed to, uint256 amount, bytes32 reason);

    // --- Errors ---
    error ACCESS_DENIED();
    error PAUSED();
    error ZERO_ADDRESS();
    error ASSET_NOT_SUPPORTED();
    error NOT_IMPLEMENTED();

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

    // --- IVault: surface (stubs) ---
    function deposit(address asset, address from, uint256 amount)
        external
        override
        notPaused
        onlySupported(asset)
    {
        // DEV41: no transfers/accounting — stub only.
        asset;
        from;
        amount;
        revert NOT_IMPLEMENTED();
    }

    function withdraw(address asset, address to, uint256 amount, bytes32 reason)
        external
        override
        notPaused
        onlySupported(asset)
    {
        // DEV41: stub — real logic to be added later.
        asset;
        to;
        amount;
        reason;
        revert NOT_IMPLEMENTED();
    }

    // --- Views ---
    function balanceOf(
        address /*asset*/
    )
        external
        pure
        override
        returns (uint256)
    {
        // DEV41: dummy 0 until accounting is implemented.
        return 0;
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
