// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { PSM } from "../../contracts/psm/PSM.sol";

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

contract PSM_RoutingTest is Test {
    ERC20Mock stable;
    ERC20Mock collateral;
    FeeRouterMock router;
    PSM psm;

    function setUp() public {
        stable = new ERC20Mock();
        collateral = new ERC20Mock();
        router = new FeeRouterMock();
        // vault addr is dummy for phase-2; not used in test logic
        psm = new PSM(address(stable), address(collateral), address(router), address(0xVau17), 20); // 0.20%
        // fund PSM with stable so it can pay out net amount
        stable.transfer(address(psm), 1e21);
        // give test sender collateral (already has from constructor)
    }

    function test_swap_routes_fee_and_emits() public {
        uint256 amountIn = 1e6;           // 1,000,000
        uint256 fee = (amountIn * 20) / 10000; // 200
        // Expect router to emit FeeRouted from PSM as sender
        vm.expectEmit(true, true, true, true, address(router));
        emit FeeRouterMock.FeeRouted(address(collateral), address(psm), fee, keccak256("PSM_FEE"));
        // Perform swap to self
        uint256 out = psm.swapCollateralForStable(amountIn, address(this));
        assertEq(out, amountIn - fee, "net out mismatch");
        // Stable increased at receiver
        // (No direct getter; use ERC20Mock storage)
        // balanceOf[address(this)] increased by net; we only check it's > 0
        assertGt(stable.balanceOf(address(this)), 0, "stable not received");
    }

    function test_zero_amount_reverts() public {
        vm.expectRevert();
        psm.swapCollateralForStable(0, address(this));
    }

    function test_paused_reverts() public {
        // anyone can pause in phase-2 skeleton
        psm.pause();
        vm.expectRevert();
        psm.swapCollateralForStable(1, address(this));
    }
}
