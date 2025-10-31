// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// [DEV-20] TreasuryVault (Phase 2 – withdraw path)
contract TreasuryVault is ReentrancyGuard, Pausable {
    address public immutable psm;
    address public immutable dao; // DAO executor for withdrawals
    mapping(address => uint256) public balances;

    event VaultDeposit(address indexed from, address indexed token, uint256 amount);
    event VaultWithdraw(address indexed to, address indexed token, uint256 amount);

    constructor(address _psm, address _dao) {
        psm = _psm;
        dao = _dao;
    }

    modifier onlyPSM() {
        require(msg.sender == psm, "not PSM");
        _;
    }

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    function depositCollateral(address token, uint256 amount) external onlyPSM {
        require(amount > 0, "amount=0");
        balances[token] += amount;
        emit VaultDeposit(msg.sender, token, amount);
    }

    function withdrawCollateral(address token, address to, uint256 amount)
        external
        onlyDAO
        nonReentrant
        whenNotPaused
    {
        require(amount > 0, "amount=0");
        uint256 bal = balances[token];
        require(bal >= amount, "insufficient");
        balances[token] = bal - amount;

        require(IERC20(token).transfer(to, amount), "transfer failed");

        emit VaultWithdraw(to, token, amount);
    }
}
