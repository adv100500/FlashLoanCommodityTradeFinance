pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SomeGoodsToken.sol";
import "./TFReceivableToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FlashLoanBorrower
 */

interface IOfftaker {
    function depositToken() external payable;
}

interface IFactoring{
    function SellReceivables(address _receivableToken) external;
}

contract FlashLoanBorrowerTraderReceivables {
    using Address for address payable;
    using Strings for uint256;    
    address payable private FlashLoanBank;
    address payable private OffTakerAddress;
    address payable private SupplierAddress;
    address payable private owner;
    address payable private factoring;
    SomeGoodsToken public immutable goodsToken;

    // Token in which receivables are issued
    ReceivableToken public receivableToken;    

    // Sales of the goods:
    uint256 public price = 120 ether;

    constructor(address payable _FlashLoanBank, address _goodsToken, address payable _OffTakerAddress, address payable _SupplierAddress, address payable _owner, address payable _factoring) {
        FlashLoanBank = _FlashLoanBank;
        goodsToken = SomeGoodsToken(_goodsToken);
        OffTakerAddress=_OffTakerAddress;
        SupplierAddress=_SupplierAddress;
        factoring=_factoring;
        owner=_owner;
    }   

    // Function called by the pool during flash loan
    function receiveEther(uint256 fee) external payable {
        require(msg.sender == FlashLoanBank, "Sender must be Flash Loan Bank");

        uint256 amountToBeRepaid = msg.value + fee;        
        
        _executeActionDuringFlashLoan(msg.value);

        require(address(this).balance >= amountToBeRepaid, "Cannot borrow that much");
        
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

        // Check balance of receivable tokens
        require(receivableToken.balanceOf(address(this))==price,"Receivable tokens were not received!");

        // Send receivable tokens to Factoring provider
        receivableToken.transfer(factoring, price);        
        IFactoring(factoring).SellReceivables(address(receivableToken));

        // Check funds received
        //require(address(this).balance>price, Strings.toString(address(this).balance));
    }
    function setToken(address _receivableToken) external {
        receivableToken=ReceivableToken(_receivableToken);
    }

    // Allow deposits of Money
    receive () external payable {}
}
