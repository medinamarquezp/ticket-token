// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TKToken.sol";
import "./TicketNFT.sol";
import {Organization, Event, Ticket} from "./Entities.sol";

contract TicketMaster {
    address private owner;
    uint256 private identifier;
    TKToken private tkToken;
    TicketNFT private ticketNFT;
    uint256[] private organizationIds;
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
    ) public onlyowner returns (uint256) {
        uint256 _id = _getIdentifier();
        organizations[_id] = Organization({
            id: _id,
            organizationAddress: _address,
            name: _name
        });
        validOrganizations[_address] = _id;
        organizationIds.push(_id);
        ticketNFT.setApproval(_address);
        return _id;
    }

    function getOrganization(
        address _address
    ) public view onlyowner returns (Organization memory) {
        return _getOrganization(_address);
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
        uint256 _eventId,
        uint256 _price
    ) public organization returns (uint256) {
        uint256 _id = _getIdentifier();
        Organization memory _organization = _getOrganization(msg.sender);
        tickets[_id] = Ticket({
            id: _id,
            organizationId: _organization.id,
            eventId: _eventId,
            ownerAddress: _organization.organizationAddress,
            price: _price
        });
        validTickets[_id] = true;
        eventTickets[_eventId].push(_id);
        ticketNFT.mintTicket(tickets[_id]);
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

    function getOrganizationIds() public view returns (uint256[] memory) {
        return organizationIds;
    }

    function getOrganizationEvents(
        uint256 _organizationId
    ) public view returns (uint256[] memory) {
        require(
            organizations[_organizationId].id != 0,
            "Organization ID not found"
        );
        return organizationEvents[_organizationId];
    }

    function getEventTickets(
        uint256 _eventId
    ) public view returns (uint256[] memory) {
        require(validEvents[_eventId], "Event ID not found");
        return eventTickets[_eventId];
    }

    function getTicket(uint256 _ticketId) public view returns (Ticket memory) {
        require(validTickets[_ticketId], "Ticket ID not found");
        return tickets[_ticketId];
    }

    function buyTicket(uint256 _ticketId) public returns (bool) {
        // Valida ID del ticket
        require(validTickets[_ticketId], "Invalid ticket Id");
        Ticket memory ticket = tickets[_ticketId];
        // Valida que el ticket pertenece a una organización (no ha sido vendido)
        require(
            validOrganizations[ticket.ownerAddress] != 0,
            "Ticket already sell"
        );
        // Valida el saldo en TKT tokens del comprador
        require(
            tkToken.balanceOf(msg.sender) > ticket.price,
            "Insufficient tokens to pay ticket price"
        );
        // Realizamos el intercambio
        tkToken.transferTokens(msg.sender, ticket.ownerAddress, ticket.price);
        ticketNFT.transferTicket(ticket.ownerAddress, msg.sender, ticket.id);
        tickets[ticket.id].ownerAddress = msg.sender;
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
