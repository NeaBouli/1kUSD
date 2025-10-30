// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

// Minimal ERC20 mock
contract TokenMock {
    string public name = "Mock";
    mapping(address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() { balanceOf[msg.sender] = 1e24; }
    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "bal");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
}

// Stateless router mock
contract FeeRouter {
    address public vault;
    event FeeRouted(address indexed token, address indexed from, uint256 amount, bytes32 indexed tag);
    constructor(address _vault){ vault = _vault; }
    function route(address token, uint256 amount, bytes32 tag) external {
        require(token != address(0) && amount > 0, "bad params");
        (bool s, ) = token.call(abi.encodeWithSignature("transfer(address,uint256)", vault, amount));
        require(s, "xfer fail");
        emit FeeRouted(token, msg.sender, amount, tag);
    }
}

contract FeeRouterTest is Test {
    TokenMock token;
    FeeRouter router;
    address vault = address(0xA11CE);

    function setUp() public {
        token = new TokenMock();
        router = new FeeRouter(vault);
    }

    function test_route_emits_event() public {
        vm.expectEmit(true, true, false, true);
        emit FeeRouter.FeeRouted(address(token), address(this), 1e18, keccak256("TEST"));
        router.route(address(token), 1e18, keccak256("TEST"));
    }
}
