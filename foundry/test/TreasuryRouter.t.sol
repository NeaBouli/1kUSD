// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/dao/TreasuryRouter.sol";

contract TreasuryRouterTest is Test {
    TreasuryRouter router;
    address dao = address(this);
    address vault = address(0xBEEF);
    address sweeper = address(0xCAFE);
    address token = address(0xF00D);

    function setUp() public {
        router = new TreasuryRouter(dao, vault, sweeper);
    }

    function testForwardEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit TreasuryRouter.TreasuryForwarded(token, 100, vault);
        vm.mockCall(token, abi.encodeWithSelector(IERC20.transfer.selector, vault, 100), abi.encode(true));
        router.forward(token, 100);
    }

    function testSweepToDAOEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit TreasuryRouter.TreasurySwept(token, 50, dao);
        router.sweepToDAO(token, 50);
    }

    function testPauseUnpauseByDAO() public {
        router.pause();
        assertTrue(router.paused());
        router.unpause();
        assertFalse(router.paused());
    }
}
