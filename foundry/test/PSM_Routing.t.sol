// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

interface IERC20 {
    function transfer(address to, uint256 val) external returns (bool);
    function transferFrom(address f, address t, uint256 v) external returns (bool);
}

contract ERC20Mock is IERC20 {
    mapping(address => uint256) public balanceOf;
    constructor() { balanceOf[msg.sender] = 1e24; }
    function transfer(address to, uint256 v) external returns (bool) { balanceOf[msg.sender]-=v; balanceOf[to]+=v; return true; }
    function transferFrom(address f, address t, uint256 v) external returns (bool) { balanceOf[f]-=v; balanceOf[t]+=v; return true; }
}

contract FeeRouterMock {
    event FeeRouted(address indexed token, address indexed from, uint256 amount, bytes32 tag);
    function route(address token, uint256 amount, bytes32 tag) external { emit FeeRouted(token, msg.sender, amount, tag); }
}

import {PSM} from "../../contracts/psm/PSM.sol";

contract PSM_RoutingTest is Test {
    ERC20Mock stable;
    ERC20Mock collateral;
    FeeRouterMock router;
    PSM psm;

    function setUp() public {
        stable = new ERC20Mock();
        collateral = new ERC20Mock();
        router = new FeeRouterMock();
        psm = new PSM(address(stable), address(collateral), address(router), 20); // 0.2%
        collateral.transfer(address(0xBEEF), 1e21); // give external addr some balance
        vm.prank(address(0xBEEF));
        collateral.transfer(address(psm), 0); // dummy to link storage
    }

    function test_swap_emits_and_routes() public {
        // prepare allowance simulation
        collateral.balanceOf(address(this)); // ensures nonzero
        stable.balanceOf(address(this));
        vm.expectEmit(true, true, true, true);
        emit FeeRouterMock.FeeRouted(address(collateral), address(psm), 2000, keccak256("PSM_FEE"));
        psm.swapCollateralForStable(1e6, address(this));
    }

    function test_zero_amount_reverts() public {
        vm.expectRevert();
        psm.swapCollateralForStable(0, address(this));
    }
}
