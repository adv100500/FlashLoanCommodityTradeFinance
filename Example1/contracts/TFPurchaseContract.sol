pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SomeGoodsToken.sol";

/**
 * @title PurchaseContract
 */

contract PurchaseContract{
    using Address for address payable;

    // Price of the goods:
    uint256 public price = 100 ether;

    // Supplier is owner of the goods:
    address payable private owner;

    // Token representing goods volume
    SomeGoodsToken public immutable goodsToken;

    constructor(address payable _ownerAddress, address _goodsToken) {
        owner=_ownerAddress;
        goodsToken = SomeGoodsToken(_goodsToken);
    }

    receive() external payable {
        uint256 balanceBefore = goodsToken.balanceOf(address(this));
        require(msg.value==price,"Incorrect purchase price");
        require(balanceBefore>0, "Not enough Goods token token balance");

       // Transfer money to the supplier 
       owner.sendValue(msg.value);

       // Send Goods token to the buyer (trader)
       goodsToken.transfer(msg.sender, balanceBefore);
    }

}
