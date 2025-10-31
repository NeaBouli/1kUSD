// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "../interfaces/IVault.sol";

contract PSM {
    address public treasuryVault;
    event VaultSynced(address indexed vault, uint256 newBalance);

    constructor(address _vault) {
        treasuryVault = _vault;
    }

    function _forwardToVault(address token, uint256 amount) internal {
        IVault(treasuryVault).depositCollateral(token, amount);
        emit VaultSynced(treasuryVault, amount);
    }
}
