// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TKToken.sol";
import "./TicketNFT.sol";
import {Organization, Event, Ticket} from "./Entities.sol";
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
    mapping(uint256 => uint256[]) private organizationEvents;
    mapping(uint256 => Ticket) private tickets;
    mapping(uint256 => bool) private validTickets;
    mapping(uint256 => uint256[]) private eventTickets;

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
    ) public organization returns (uint256) {
        uint256 _id = _getIdentifier();
        Organization memory _organization = _getOrganization(msg.sender);
        events[_id] = Event({
            id: _id,
            organizationId: _organization.id,
            name: _name,
            description: _description,
            date: _date
        });
        validEvents[_id] = true;
        organizationEvents[_organization.id].push(_id);
        return _id;
    }

    function getLastEvent() public view organization returns (Event memory) {
        Organization memory _organization = _getOrganization(msg.sender);
        uint256 lastIndex = organizationEvents[_organization.id].length - 1;
        uint256 eventId = organizationEvents[_organization.id][lastIndex];
        return events[eventId];
    }

    function createTicket(
        uint256 _eventId
    ) public organization returns (uint256) {
        uint256 _id = _getIdentifier();
        Organization memory _organization = _getOrganization(msg.sender);
        tickets[_id] = Ticket({
            id: _id,
            organizationId: _organization.id,
            eventId: _eventId,
            ownerAddress: _organization.organizationAddress
        });
        validTickets[_id] = true;
        eventTickets[_eventId].push(_id);
        return _id;
    }

    function getLastTicket(
        uint256 _eventId
    ) public view organization returns (Ticket memory) {
        Event memory _event = events[_eventId];
        Organization memory _organization = _getOrganization(msg.sender);
        require(_event.organizationId == _organization.id, "Event not found");
        uint256 lastIndex = eventTickets[_eventId].length - 1;
        uint256 eventId = eventTickets[_eventId][lastIndex];
        return tickets[eventId];
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
