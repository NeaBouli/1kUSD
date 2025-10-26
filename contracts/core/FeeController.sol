pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeController is Ownable {
    mapping(bytes32 => uint256) public feeBps;
    event FeeSet(bytes32 indexed key, uint256 value);

    constructor() {
        feeBps[keccak256("TREASURY_FORWARD_BPS")] = 100; // 1%
        feeBps[keccak256("DAO_MAINTENANCE_BPS")] = 50;   // 0.5%
    }

    function setFee(bytes32 key, uint256 value) external onlyOwner {
        require(value <= 10_000, "Too high");
        feeBps[key] = value;
        emit FeeSet(key, value);
    }

    function getFeeBps(bytes32 key) external view returns (uint256) {
        return feeBps[key];
    }
}
