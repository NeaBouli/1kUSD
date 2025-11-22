// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title BuybackVault
/// @notice Minimal, safety-gated vault for protocol buybacks.
/// @dev
/// - Hält 1kUSD und ein Ziel-Asset (z.B. Governance- oder LP-Token).
/// - Nur die DAO darf Mittel zuführen/abziehen.
/// - Konkrete Buyback-Execution (DEX/PSM) wird in späteren DEV-Steps ergänzt.
contract BuybackVault {
    // --- Immutables & Storage ---

    /// @notice Modul-ID für SafetyAutomata
    bytes32 public constant MODULE_ID = keccak256("BUYBACK_VAULT");

    /// @notice Governance/DAO-Admin
    address public immutable dao;

    /// @notice Safety-Modul, das pausierbare Operationen erzwingt
    ISafetyAutomata public immutable safety;

    /// @notice Stablecoin (1kUSD) für Buybacks
    IERC20 public immutable stable;

    /// @notice Ziel-Asset, das zurückgekauft werden soll (z.B. GOV- oder LP-Token)
    IERC20 public immutable asset;

    // --- Events ---

    event FundStable(address indexed from, uint256 amount);
    event WithdrawStable(address indexed to, uint256 amount);
    event WithdrawAsset(address indexed to, uint256 amount);

    // --- Errors ---

    error ZERO_ADDRESS();
    error ACCESS_DENIED();
    error PAUSED();

    // --- Modifiers ---

    modifier onlyDAO() {
        if (msg.sender != dao) revert ACCESS_DENIED();
        _;
    }

    modifier notPaused() {
        if (safety.isPaused(MODULE_ID)) revert PAUSED();
        _;
    }

    // --- Constructor ---

    constructor(
        address _dao,
        ISafetyAutomata _safety,
        IERC20 _stable,
        IERC20 _asset
    ) {
        if (_dao == address(0)) revert ZERO_ADDRESS();
        if (address(_safety) == address(0)) revert ZERO_ADDRESS();
        if (address(_stable) == address(0)) revert ZERO_ADDRESS();
        if (address(_asset) == address(0)) revert ZERO_ADDRESS();

        dao = _dao;
        safety = _safety;
        stable = _stable;
        asset = _asset;
    }

    // --- Core API ---

    /// @notice DAO funded den Vault mit 1kUSD (pull from DAO)
    /// @dev DAO muss vorher `stable.approve(address(this), amount)` gesetzt haben.
    function fundStable(uint256 amount) external onlyDAO notPaused {
        if (amount == 0) return;
        stable.transferFrom(msg.sender, address(this), amount);
        emit FundStable(msg.sender, amount);
    }

    /// @notice DAO kann 1kUSD aus dem Vault abziehen (z.B. bei Strategie-Wechsel)
    function withdrawStable(address to, uint256 amount) external onlyDAO {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) return;
        stable.transfer(to, amount);
        emit WithdrawStable(to, amount);
    }

    /// @notice DAO kann das Ziel-Asset aus dem Vault abziehen
    function withdrawAsset(address to, uint256 amount) external onlyDAO {
        if (to == address(0)) revert ZERO_ADDRESS();
        if (amount == 0) return;
        asset.transfer(to, amount);
        emit WithdrawAsset(to, amount);
    }

    // --- View Helpers ---

    /// @notice Aktueller 1kUSD-Bestand im Vault
    function stableBalance() external view returns (uint256) {
        return stable.balanceOf(address(this));
    }

    /// @notice Aktueller Ziel-Asset-Bestand im Vault
    function assetBalance() external view returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
