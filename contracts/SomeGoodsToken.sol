// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SomeGoodsToken
 */
contract SomeGoodsToken is ERC20 {

    // Decimals are set to 18 by default in `ERC20`
    constructor() ERC20("SomeGoodsToken", "GOODS") {
        uint256 mintAmount=100*10**18;

        _mint(msg.sender, mintAmount);
    }
}