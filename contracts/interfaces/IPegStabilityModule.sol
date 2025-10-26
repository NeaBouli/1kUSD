// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPegStabilityModule {
    function setFees(uint256 mintFeeBps, uint256 redeemFeeBps) external;
}
