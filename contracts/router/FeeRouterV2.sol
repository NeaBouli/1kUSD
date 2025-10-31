// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FeeRouterV2 is ReentrancyGuard, Pausable {
address public dao;
mapping(bytes32 => address) public routeMap;

event FeeRouted(bytes32 indexed tag, address indexed token, uint256 amount, address indexed to);
event RouteSet(bytes32 indexed tag, address indexed vault);

modifier onlyDAO() {
    require(msg.sender == dao, "not DAO");
    _;
}

constructor(address _dao) {
    dao = _dao;
}

function setRoute(bytes32 tag, address vault) external onlyDAO {
    routeMap[tag] = vault;
    emit RouteSet(tag, vault);
}

function route(bytes32 tag, address token, uint256 amount)
    external
    nonReentrant
    whenNotPaused
{
    require(amount > 0, "amount=0");
    address vault = routeMap[tag];
    require(vault != address(0), "route missing");
    require(IERC20(token).transfer(vault, amount), "transfer failed");
    emit FeeRouted(tag, token, amount, vault);
}


}
