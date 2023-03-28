// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TKToken is ERC20 {
    constructor() ERC20("Ticket Token", "TKT") {
        _mint(_msgSender(), 10000 * 10 ** 18);
    }
}
