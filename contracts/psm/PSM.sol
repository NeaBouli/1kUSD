// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @notice Minimal ERC20 interface (success bool style)
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/// @notice Minimal FeeRouter interface (stateless, push model)
interface IFeeRouter {
    function route(address token, uint256 amount, bytes32 tag) external;
}

/// @title Peg Stability Module (PSM) — Phase 1 (integration minimal)
/// @notice Pulls collateral from user, routes fee via FeeRouter to TreasuryVault, sends net stable to receiver.
contract PSM {
    address public immutable stableToken;      // 1kUSD (ERC20)
    address public immutable collateralToken;  // backing asset (ERC20)
    address public immutable feeRouter;        // stateless router (push to TreasuryVault)
    uint256 public feeBps;                     // fee in basis points (e.g., 20 = 0.20%)

    bytes32 internal constant TAG_PSM_FEE = keccak256("PSM_FEE");

    event Swapped(address indexed sender, uint256 amountIn, uint256 amountOut, address indexed to);
    event FeeSent(address indexed token, uint256 feeAmount);

    error ZeroAmount();
    error TransferInFailed();
    error TransferOutFailed();
    error FeeTransferFailed();

    constructor(address _stable, address _collateral, address _router, uint256 _feeBps) {
        stableToken = _stable;
        collateralToken = _collateral;
        feeRouter = _router;
        feeBps = _feeBps;
    }

    /// @notice Swap collateral -> stable (simplified), route fee via FeeRouter.
    /// @dev Assumes caller approved `amountIn` of collateral to this contract.
    function swapCollateralForStable(uint256 amountIn, address to) external returns (uint256 amountOut) {
        if (amountIn == 0) revert ZeroAmount();

        // --- Checks
        uint256 fee = (amountIn * feeBps) / 10_000;
        uint256 net = amountIn - fee;

        // --- Effects (none persistent in v1 minimal)

        // --- Interactions
        // Pull collateral from user to this PSM
        if (!IERC20(collateralToken).transferFrom(msg.sender, address(this), amountIn)) {
            revert TransferInFailed();
        }

        // Hand fee to router, then instruct router to push to TreasuryVault
        if (fee > 0) {
            if (!IERC20(collateralToken).transfer(feeRouter, fee)) revert FeeTransferFailed();
            IFeeRouter(feeRouter).route(collateralToken, fee, TAG_PSM_FEE);
            emit FeeSent(collateralToken, fee);
        }

        // Send out stable (assumes this PSM holds/mints sufficient stable for phase-1 test)
        if (!IERC20(stableToken).transfer(to, net)) revert TransferOutFailed();

        emit Swapped(msg.sender, amountIn, net, to);
        return net;
    }
}
