// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TKToken is ERC20 {
    uint256 changeFactor;

    constructor() ERC20("Ticket Token", "TKT") {
        changeFactor = 10;
        _initializeBalance();
        _mint(_msgSender(), 100 * changeFactor ** 18);
    }

    function buyTokens() public payable returns (bool) {
        require(msg.value > 0, "Funds required");
        uint256 amount = msg.value * changeFactor;
        _approve(address(this), _msgSender(), amount);
        transferFrom(address(this), _msgSender(), amount);
        return true;
    }

    function sellTokens(uint256 _value) public returns (bool) {
        require(
            _value <= balanceOf(_msgSender()),
            "Insufficient tokens to sell"
        );
        transfer(address(this), _value);
        uint256 amount = (_value / changeFactor);
        payable(_msgSender()).transfer(amount);
        return true;
    }

    function _initializeBalance() private {
        uint256 initialBalance = 10000000 * changeFactor ** 18;
        _mint(address(this), initialBalance);
    }
}
