pragma solidity ^0.8.20;

interface IFeeController {
    function getFeeBps(bytes32 key) external view returns (uint256);
}
