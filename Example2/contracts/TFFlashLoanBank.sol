pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title FlashLoanBank
 */

interface IBorrower {
    function receiveEther(uint256 fee) external payable;
}


contract FlashLoanBank is ReentrancyGuard {

    using Address for address;

    uint256 private constant FIXED_FEE = 1 ether; 

    function fixedFee() external pure returns (uint256) {
        return FIXED_FEE;
    }

    function flashLoan(address borrower, uint256 borrowAmount) external nonReentrant {

        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= borrowAmount, "Not enough funds in the bank");

        require(borrower.isContract(), "Borrower must be a deployed contract");

        // Transfer ETH and handle control to receiver
        IBorrower(borrower).receiveEther{value: borrowAmount}(FIXED_FEE);
  
        require(
            address(this).balance >= balanceBefore + FIXED_FEE,
            "Flash loan with interest hasn't been paid back"
        );
    }

    // Allow deposits of ETH
    receive () external payable {}
}
