// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../oracle/OracleAggregator.sol";
import "../router/FeeRouterV2.sol";

contract PSMSwapCore is ReentrancyGuard, Pausable {
    address public dao;
    OracleAggregator public oracle;
    FeeRouterV2 public feeRouter;
    address public stableToken;
    uint256 public feeBps = 50; // 0.5%

    event SwapExecuted(address indexed user, address indexed token, uint256 amountIn, uint256 stableOut);
    event FeeUpdated(uint256 newFee);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao, address _oracle, address _feeRouter, address _stableToken) {
        dao = _dao;
        oracle = OracleAggregator(_oracle);
        feeRouter = FeeRouterV2(_feeRouter);
        stableToken = _stableToken;
    }

    function setFee(uint256 newFee) external onlyDAO {
        feeBps = newFee;
        emit FeeUpdated(newFee);
    }

    function swapCollateralForStable(address token, uint256 amountIn)
        external
        nonReentrant
        whenNotPaused
    {
        require(amountIn > 0, "amount=0");
        uint256 price = oracle.getMedianPrice();
        require(price > 0, "price=0");

        uint256 stableOut = (amountIn * price) / 1e18;
        uint256 fee = (stableOut * feeBps) / 10000;
        stableOut -= fee;

        require(IERC20(token).transferFrom(msg.sender, address(this), amountIn), "collateral transfer failed");
        feeRouter.route(keccak256("PSM_FEE"), stableToken, fee);

        require(IERC20(stableToken).transfer(msg.sender, stableOut), "stable transfer failed");
        emit SwapExecuted(msg.sender, token, amountIn, stableOut);
    }
}
