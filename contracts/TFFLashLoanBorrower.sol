pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SomeGoodsToken.sol";


/**
 * @title FlashLoanBorrower
 */

interface IOfftaker {
    function depositToken() external payable;
}

contract FlashLoanBorrowerTrader {
    using Address for address payable;
    
    address payable private FlashLoanBank;
    address payable private OffTakerAddress;
    address payable private SupplierAddress;
    address payable private owner;
    SomeGoodsToken public immutable goodsToken;

    // Sales of the goods:
    uint256 public price = 120 ether;

    constructor(address payable _FlashLoanBank, address _goodsToken, address payable _OffTakerAddress, address payable _SupplierAddress, address payable _owner) {
        FlashLoanBank = _FlashLoanBank;
        goodsToken = SomeGoodsToken(_goodsToken);
        OffTakerAddress=_OffTakerAddress;
        SupplierAddress=_SupplierAddress;
        owner=_owner;
    }   

    // Function called by the pool during flash loan
    function receiveEther(uint256 fee) external payable {
        require(msg.sender == FlashLoanBank, "Sender must be Flash Loan Bank");

        uint256 amountToBeRepaid = msg.value + fee;        
        
        _executeActionDuringFlashLoan(msg.value);

        require(address(this).balance >= amountToBeRepaid, "Not enough funds to repay the flash loan");
        
        // Return funds to FlashLoanBank
        FlashLoanBank.sendValue(amountToBeRepaid);

        // Send profit to the owner
        uint256 balanceMoneyAfter = address(this).balance;
        owner.sendValue(balanceMoneyAfter);
    }

    // Internal function where the funds received are used
    function _executeActionDuringFlashLoan(uint256 _purchaseAmount) internal { 

        require(SupplierAddress.isContract(), "Supplier must be a deployed contract");
        require(payable(OffTakerAddress).isContract(), "Seller must be a deployed contract");

        // Send money to the supplier's contract:
        uint256 balanceMoney = address(this).balance;
        require(balanceMoney==_purchaseAmount, "Not enough money to pay the supplier");
        SupplierAddress.sendValue(_purchaseAmount);

        // Check received goods token balance
        uint256 balanceToken= goodsToken.balanceOf(address(this));
        require(balanceToken>0, "Not enough goods token balance");

        // Transfer goods token to the off-taker
        goodsToken.transfer(OffTakerAddress, balanceToken);
        IOfftaker(OffTakerAddress).depositToken();

    }

    // Allow deposits of Money
    receive () external payable {}
}
