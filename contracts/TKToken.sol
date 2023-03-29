// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TKToken is ERC20 {
    uint256 changeFactor;
    uint256 salesCommissionPercentage;
    address public owner;
    mapping(address => bool) public authorized;

    constructor() ERC20("Ticket Token", "TKT") {
        owner = msg.sender;
        changeFactor = 10;
        salesCommissionPercentage = 3;
        _initializeBalance();
        _mint(_msgSender(), 100 * changeFactor ** 18);
    }

    function authorize(
        address _address,
        bool _status
    ) public onlyowner returns (bool) {
        authorized[_address] = _status;
        return true;
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

    function transferTokens(
        address _from,
        address _to,
        uint256 _amount
    ) public onlyauthorized returns (bool) {
        uint256 commission = (_amount * salesCommissionPercentage) / 100;
        uint256 amountToPay = _amount - commission;
        _approve(_from, _msgSender(), commission);
        _approve(_from, _to, amountToPay);
        _transfer(_from, _msgSender(), commission);
        _transfer(_from, _to, amountToPay);
        return true;
    }

    function _initializeBalance() private {
        uint256 initialBalance = 10000000 * changeFactor ** 18;
        _mint(address(this), initialBalance);
    }

    modifier onlyowner() {
        require(
            msg.sender == owner,
            "This operation is only available for owner address"
        );
        _;
    }

    modifier onlyauthorized() {
        require(
            msg.sender == owner || authorized[msg.sender],
            "This operation is only available for authorized addresses"
        );
        _;
    }
}
