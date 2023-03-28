// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ticket} from "./Entities.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketNFT is ERC721 {
    address public owner;
    string public baseURI;
    mapping(address => bool) public authorized;

    constructor() ERC721("TicketNFT", "TKTNFT") {
        owner = msg.sender;
    }

    function authorize(
        address _address,
        bool _status
    ) public onlyowner returns (bool) {
        authorized[_address] = _status;
        return true;
    }

    function mintTicket(
        Ticket memory _ticket
    ) public onlyauthorized returns (bool) {
        _safeMint(_ticket.ownerAddress, _ticket.id);
        return true;
    }

    function setBaseURI(
        string memory _uri
    ) public onlyowner returns (string memory) {
        baseURI = _uri;
        return baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
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
