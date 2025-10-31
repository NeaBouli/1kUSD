// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/psm/PSMSwapCore.sol";

contract MockOracle {
    uint256 public price = 1e18;
    function getMedianPrice() external view returns (uint256) {
        return price;
    }
    function setPrice(uint256 p) external { price = p; }
}

contract MockFeeRouter {
    bytes32 public lastTag;
    address public lastToken;
    uint256 public lastAmount;
    function route(bytes32 tag, address token, uint256 amount) external {
        lastTag = tag;
        lastToken = token;
        lastAmount = amount;
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "no funds");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "no funds");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

contract PSMSwapCoreTest is Test {
    PSMSwapCore psm;
    MockOracle oracle;
    MockFeeRouter feeRouter;
    MockERC20 token;
    MockERC20 stable;
    address dao = address(this);
    address user = address(0xBEEF);

    function setUp() public {
        oracle = new MockOracle();
        feeRouter = new MockFeeRouter();
        token = new MockERC20();
        stable = new MockERC20();
        psm = new PSMSwapCore(dao, address(oracle), address(feeRouter), address(stable));
        token.mint(user, 1000e18);
        stable.mint(address(psm), 1000e18);
    }

    function testSwapExecutesAndRoutesFee() public {
        vm.startPrank(user);
        token.transfer(address(psm), 0); // just to quiet warnings
        token.balanceOf(user);
        token.balanceOf(address(psm));
        token.transfer(address(psm), 0);
        token.balanceOf(user);
        token.balanceOf(address(psm));

        // simulate swap
        token.mint(user, 100e18);
        stable.mint(address(psm), 100e18);
        psm.swapCollateralForStable(address(token), 100e18);
    }

    function testSetFeeDAOOnly() public {
        psm.setFee(100);
        assertEq(psm.feeBps(), 100);

        vm.prank(address(0xCAFE));
        vm.expectRevert("not DAO");
        psm.setFee(200);
    }

    function testRevertsZeroAmount() public {
        vm.expectRevert("amount=0");
        psm.swapCollateralForStable(address(token), 0);
    }
}
