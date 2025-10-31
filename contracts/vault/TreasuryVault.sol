// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

// [DEV-19] TreasuryVault (Phase 2)
contract TreasuryVault {
    address public immutable psm;
    mapping(address => uint256) public balances;

    event VaultDeposit(address indexed from, address indexed token, uint256 amount);

    modifier onlyPSM() {
        require(msg.sender == psm, "not PSM");
        _;
    }

    constructor(address _psm) {
        psm = _psm;
    }

    function depositCollateral(address token, uint256 amount) external onlyPSM {
        require(amount > 0, "amount=0");
        balances[token] += amount;
        emit VaultDeposit(msg.sender, token, amount);
    }
}
