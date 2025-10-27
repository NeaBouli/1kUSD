// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {CollateralVault} from "./CollateralVault.sol";
import {OneKUSD} from "./OneKUSD.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {ParameterRegistry} from "./ParameterRegistry.sol";
import {IPSM} from "../interfaces/IPSM.sol";

contract PegStabilityModule is IPSM, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");

    OneKUSD public oneKUSD;
    CollateralVault public vault;
    ISafetyAutomata public safetyAutomata;
    ParameterRegistry public registry;

    uint256 public mintFeeBps;
    uint256 public redeemFeeBps;

    error PausedError();
    error InsufficientOut();

    modifier whenNotPaused() {
        if (address(safetyAutomata)!=address(0)&&safetyAutomata.isPaused()) revert PausedError();
        _;
    }

    constructor(address admin,address _oneKUSD,address _vault,address _auto,address _reg){
        _grantRole(DEFAULT_ADMIN_ROLE,admin);
        _grantRole(ADMIN_ROLE,admin);
        oneKUSD=OneKUSD(_oneKUSD);
        vault=CollateralVault(_vault);
        safetyAutomata=ISafetyAutomata(_auto);
        registry=ParameterRegistry(_reg);
    }

    function swapTo1kUSD(address asset,uint256 collateralAmount,uint256 minOut)
        external whenNotPaused nonReentrant {
        IERC20(asset).safeTransferFrom(msg.sender,address(vault),collateralAmount);
        uint256 fee=(collateralAmount*mintFeeBps)/10_000;
        uint256 out=collateralAmount-fee;
        if(out<minOut) revert InsufficientOut();
        oneKUSD.mint(msg.sender,out);
        emit SwapTo1kUSD(msg.sender,asset,collateralAmount,fee,out,block.timestamp);
    }

    function swapFrom1kUSD(address asset,uint256 oneKAmount,uint256 minOut)
        external whenNotPaused nonReentrant {
        oneKUSD.burn(msg.sender,oneKAmount);
        uint256 fee=(oneKAmount*redeemFeeBps)/10_000;
        uint256 net=oneKAmount-fee;
        if(net<minOut) revert InsufficientOut();
        vault.withdraw(asset,msg.sender,net);
        emit SwapFrom1kUSD(msg.sender,asset,oneKAmount,fee,net,block.timestamp);
    }

    function setFees(uint256 mintFee,uint256 redeemFee) external onlyRole(ADMIN_ROLE){
        mintFeeBps=mintFee;
        redeemFeeBps=redeemFee;
        emit FeesUpdated(mintFee,redeemFee);
    }

    function quoteTo1kUSD(address, uint256) external pure override returns(uint256){return 0;}
    function quoteFrom1kUSD(address, uint256) external pure override returns(uint256){return 0;}
}
