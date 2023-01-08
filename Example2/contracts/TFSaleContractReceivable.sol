// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SomeGoodsToken.sol";
import "./TFReceivableToken.sol";

/**
 * @title SalesContractReceivable
 */
interface ITrader{
    function setToken(address _receivableToken) external;
}

contract SalesContractReceivable {
        using Address for address payable;

    // Seller address:
    address payable private owner;
    
    // Token representing goods volume
    SomeGoodsToken public immutable goodsToken;
    
    // Supplier address
    address payable private SupplierAddress;
    
    // Token in which receivables are issued
    ReceivableToken public immutable receivableToken;

    // Sales of the goods:
    uint256 public price = 120 ether;    

    constructor(address payable _ownerAddress, address _goodsToken) {
        owner=_ownerAddress;
        goodsToken = SomeGoodsToken(_goodsToken);
        receivableToken = new ReceivableToken();
    }   
        // Final off-taker sets the address of his supplier (trader)
        function setSupplier(address payable _SupplierAddress) public {
        SupplierAddress=_SupplierAddress;
        }

        // Function will be called by the trader
        function depositToken() external payable {
        require(SupplierAddress.isContract(), "Seller must be a deployed contract");
              
        // Check goods token balance
        uint256 balanceToken= goodsToken.balanceOf(address(this));
        require(balanceToken>0, "Not enough Goods token balance"); 

        // Send receivable token to the supplier (trader)
        receivableToken.mint(SupplierAddress, price);

        // Send address of minted receivable token
        ITrader(SupplierAddress).setToken(address(receivableToken));

        // Transfer the token to the seller
        goodsToken.transfer(owner, balanceToken);
    }
    // Allow deposits of Money
    receive () external payable {}    
}