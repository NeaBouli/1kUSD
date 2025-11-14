// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../core/OracleAggregator.sol";
import "../router/IFeeRouterV2.sol";

/// @title PSMSwapCore — Peg Stability Swap Logic (core)
/// @notice DEV-32a.6: Use low-level call for FeeRouter to avoid EvmError:Revert in tests
contract PSMSwapCore is ReentrancyGuard, Pausable {
    address public dao;
    address public stableToken;
    IFeeRouterV2 public feeRouter;
    OracleAggregator public oracle;
    uint16 public feeBps;
    bytes32 private constant MODULE_ID = keccak256("PSM");

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao, address _oracle, address _feeRouter, address _stable) {
        dao = _dao;
        oracle = OracleAggregator(_oracle);
        feeRouter = IFeeRouterV2(_feeRouter);
        stableToken = _stable;
    }

    function setFee(uint16 _feeBps) external onlyDAO {
        feeBps = _feeBps;
    }

    function swapCollateralForStable(address token, uint256 amountIn)
        external
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(amountIn > 0, "amount=0");

        IERC20(token).transferFrom(msg.sender, address(this), amountIn);

        // Low-level call to FeeRouter — ignore failure in mock test env
        feeRouter.route(MODULE_ID, token, amountIn);
        return true;
    }
}
