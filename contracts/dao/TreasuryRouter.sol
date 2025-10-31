// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {
    function depositCollateral(address token, uint256 amount) external;
}

interface IVaultSweeper {
    function sweep(address token, uint256 amount, address to) external;
}

/// @title TreasuryRouter
/// @notice Routes protocol fees to the TreasuryVault and lets DAO trigger sweeps.
contract TreasuryRouter is ReentrancyGuard, Pausable {
    address public immutable dao;
    address public immutable vault;
    address public immutable sweeper;

    event TreasuryForwarded(address indexed token, uint256 amount, address indexed to);
    event TreasurySwept(address indexed token, uint256 amount, address indexed to);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao, address _vault, address _sweeper) {
        require(_dao != address(0) && _vault != address(0) && _sweeper != address(0), "zero addr");
        dao = _dao;
        vault = _vault;
        sweeper = _sweeper;
    }

    /// @notice Forward tokens from FeeRouterV2 to TreasuryVault.
    function forward(address token, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "amount=0");
        require(IERC20(token).transfer(vault, amount), "transfer failed");
        emit TreasuryForwarded(token, amount, vault);
    }

    /// @notice DAO triggers sweeping of excess tokens via VaultSweeper.
    function sweepToDAO(address token, uint256 amount)
        external
        onlyDAO
        nonReentrant
    {
        require(amount > 0, "amount=0");
        IVaultSweeper(sweeper).sweep(token, amount, dao);
        emit TreasurySwept(token, amount, dao);
    }

    /// @notice Emergency pause for all routing ops.
    function pause() external onlyDAO { _pause(); }
    function unpause() external onlyDAO { _unpause(); }
}
