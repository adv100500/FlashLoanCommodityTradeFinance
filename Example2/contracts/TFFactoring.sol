// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./TFReceivableToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Factoring
 */

contract Factoring is ReentrancyGuard {
    using Address for address;
    using Strings for uint256;
    uint256 private constant FIXED_FEE = 3 ether; 
    // Token in which receivables are issued
    ReceivableToken public receivableToken;    


    function fixedFee() external pure returns (uint256) {
        return FIXED_FEE;
    }
    
    function SellReceivables(address _receivableToken) external nonReentrant {

        require(msg.sender.isContract(), "Borrower must be a deployed contract");

        receivableToken=ReceivableToken(_receivableToken);

        uint256 balanceOfReceivable =receivableToken.balanceOf(address(this));
        
        require(balanceOfReceivable >= FIXED_FEE, Strings.toString(balanceOfReceivable));//"Amount of receivable should be greater than zero");

        // Send funds to Trader
        (bool ethSent, ) = msg.sender.call{value: (balanceOfReceivable-FIXED_FEE)}("");        
        require(ethSent);


    }        

    // Allow deposits of ETH
    receive () external payable {}

}