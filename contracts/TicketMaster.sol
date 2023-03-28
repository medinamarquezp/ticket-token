// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TKToken.sol";
import "./TicketNFT.sol";
import {Organization, Event} from "./Entities.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TicketMaster {
    address private owner;
    uint256 private identifier;
    TKToken private tkToken;
    TicketNFT private ticketNFT;
    mapping(address => uint256) private validOrganizations;
    mapping(uint256 => Organization) private organizations;
    mapping(uint256 => Event) private events;
    mapping(uint256 => bool) private validEvents;
    mapping(uint256 => uint256) private organizationEvents;

    constructor(address _tkToken, address _ticketNFT) {
        owner = msg.sender;
        tkToken = TKToken(_tkToken);
        ticketNFT = TicketNFT(_ticketNFT);
        identifier = block.timestamp;
    }

    function createOrganization(
        address _address,
        string memory _name
    ) public onlyowner returns (bool) {
        uint256 _id = _getIdentifier();
        organizations[_id] = Organization({
            id: _id,
            organizationAddress: _address,
            name: _name
        });
        validOrganizations[_address] = _id;
        return true;
    }

    function createEvent(
        string memory _name,
        string memory _description,
        uint256 _date
    ) public organization returns (bool) {
        uint256 _id = _getIdentifier();
        Organization memory _organization = _getOrganization(msg.sender);
        events[_id] = Event({
            id: _id,
            organization: _organization,
            name: _name,
            description: _description,
            date: _date
        });
        validEvents[_id] = true;
        organizationEvents[_organization.id] = _id;
        return true;
    }

    function _getIdentifier() private returns (uint256) {
        identifier += 1;
        return identifier;
    }

    function _getOrganization(
        address _address
    ) private view returns (Organization memory) {
        uint256 id = validOrganizations[_address];
        return organizations[id];
    }

    modifier organization() {
        require(validOrganizations[msg.sender] != 0, "Invalid organization");
        _;
    }

    modifier onlyowner() {
        require(
            msg.sender == owner,
            "This operation is only available for owner address"
        );
        _;
    }
}
