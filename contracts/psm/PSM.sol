// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFeeRouter {
    function route(address token, uint256 amount, bytes32 tag) external;
}

// [DEV-17] Peg Stability Module (Phase 2 – guarded swap)
contract PSM is ReentrancyGuard, Pausable {
    address public immutable stableToken;
    address public immutable collateralToken;
    address public immutable feeRouter;
    address public immutable treasuryVault;
    uint256 public feeBps;

    event Swapped(address indexed sender, uint256 amountIn, uint256 amountOut, address to);
    event FeeSent(address indexed token, uint256 feeAmount);
    event VaultSynced(address indexed vault, uint256 newBalance);

    constructor(
        address _stable,
        address _collateral,
        address _router,
        address _vault,
        uint256 _feeBps
    ) {
        stableToken = _stable;
        collateralToken = _collateral;
        feeRouter = _router;
        treasuryVault = _vault;
        feeBps = _feeBps;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "amount=0");
        _;
    }

    function swapCollateralForStable(uint256 amountIn, address to)
        external
        validAmount(amountIn)
        nonReentrant
        whenNotPaused
        returns (uint256 netOut)
    {
        // Pull collateral from sender
        require(IERC20(collateralToken).transferFrom(msg.sender, address(this), amountIn), "transferFrom failed");

        uint256 fee = (amountIn * feeBps) / 10_000;
        uint256 net = amountIn - fee;

        // Route fee
        if (fee > 0) {
            IFeeRouter(feeRouter).route(collateralToken, fee, keccak256("PSM_FEE"));
            emit FeeSent(collateralToken, fee);
        }

        // Send out stable
        require(IERC20(stableToken).transfer(to, net), "transfer failed");
        emit Swapped(msg.sender, amountIn, net, to);
        return net;
    }

    function pause() external whenNotPaused { _pause(); }
    function unpause() external whenPaused { _unpause(); }
}
