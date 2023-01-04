// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SomeGoodsToken.sol";

/**
 * @title SalesContract
 */

contract SalesContract {
        using Address for address payable;

    // Seller address:
    address payable private owner;
    
    // Token representing goods volume
    SomeGoodsToken public immutable goodsToken;
    
    // Supplier address
    address payable private SupplierAddress;
    
    // Sales of the goods:
    uint256 public price = 120 ether;

    constructor(address payable _ownerAddress, address _goodsToken) {
        owner=_ownerAddress;
        goodsToken = SomeGoodsToken(_goodsToken);

    }   
        // Final off-taker sets the address of his supplier (trader)
        function setSupplier(address payable _SupplierAddress) public {
        SupplierAddress=_SupplierAddress;
        }

        // Function will be called by the trader
        function depositToken() external payable {
        require(SupplierAddress.isContract(), "Seller must be a deployed contract");
        uint256 balanceMoney = address(this).balance;
        require(balanceMoney==price, "Not enough money to pay the supplier");

        // Send payment to the supplier
        SupplierAddress.sendValue(price);
        
        // Check token balance
        uint256 balanceToken= goodsToken.balanceOf(address(this));
        require(balanceToken>0, "Not enough Goods token balance");        
        
        // Transfer the token to the seller
        goodsToken.transfer(owner, balanceToken);
    }
    // Allow deposits of Money
    receive () external payable {}    
}