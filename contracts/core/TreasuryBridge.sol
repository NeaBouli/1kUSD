pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IFeeController {
    function getFeeBps(bytes32 key) external view returns (uint256);
}

contract TreasuryBridge is Ownable, ReentrancyGuard {
    event TreasuryDeposit(address indexed from, uint256 amount);
    event TreasuryWithdraw(address indexed to, uint256 amount);
    event FeeForwarded(address indexed to, uint256 amount);
    event FeeControllerUpdated(address controller);
    event DaoWalletUpdated(address dao);

    address public daoWallet;
    IFeeController public feeController;

    constructor(address _dao, address _feeController) {
        daoWallet = _dao;
        feeController = IFeeController(_feeController);
    }

    receive() external payable {
        emit TreasuryDeposit(msg.sender, msg.value);
    }

    function forwardFees() external nonReentrant {
        require(address(this).balance > 0, "Nothing to forward");
        uint256 feeBps = feeController.getFeeBps(keccak256("TREASURY_FORWARD_BPS"));
        uint256 fee = (address(this).balance * feeBps) / 10_000;
        (bool ok1, ) = daoWallet.call{value: fee}("");
        require(ok1, "DAO transfer failed");
        emit FeeForwarded(daoWallet, fee);
    }

    function withdraw(address payable to, uint256 amount) external onlyOwner {
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
        emit TreasuryWithdraw(to, amount);
    }

    function updateFeeController(address newController) external onlyOwner {
        feeController = IFeeController(newController);
        emit FeeControllerUpdated(newController);
    }

    function updateDaoWallet(address newDao) external onlyOwner {
        daoWallet = newDao;
        emit DaoWalletUpdated(newDao);
    }
}
