// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct Organization {
    uint256 id;
    address organizationAddress;
    string name;
}

struct Event {
    uint256 id;
    uint256 organizationId;
    string name;
    string description;
    uint256 date;
}

struct Ticket {
    uint256 id;
    uint256 organizationId;
    uint256 eventId;
    address ownerAddress;
}
