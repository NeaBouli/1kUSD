// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultSweeper is ReentrancyGuard, Pausable {
    address public dao;
    mapping(address => bool) public collateralWhitelist;

    event VaultSwept(address indexed token, uint256 amount, address indexed to);
    event CollateralWhitelisted(address indexed token, bool allowed);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao) {
        dao = _dao;
    }

    function setCollateralWhitelist(address token, bool allowed) external onlyDAO {
        collateralWhitelist[token] = allowed;
        emit CollateralWhitelisted(token, allowed);
    }

    function sweep(address token, uint256 amount, address to)
        external
        onlyDAO
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "amount=0");
        require(!collateralWhitelist[token], "protected");
        require(IERC20(token).transfer(to, amount), "transfer failed");
        emit VaultSwept(token, amount, to);
    }
}
