pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceRelay is Ownable {
    event ParameterChanged(address indexed target, bytes data);

    modifier onlyDAO() {
        require(msg.sender == owner(), "Not DAO");
        _;
    }

    function relay(address target, bytes calldata data) external onlyDAO {
        (bool ok, ) = target.call(data);
        require(ok, "Call failed");
        emit ParameterChanged(target, data);
    }
}
