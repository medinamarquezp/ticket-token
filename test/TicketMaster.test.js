const truffleAssert = require("truffle-assertions");
const TKToken = artifacts.require("TKToken");
const TicketNFT = artifacts.require("TicketNFT");
const TicketMaster = artifacts.require("TicketMaster");

contract("TicketNFT tests", (accounts) => {
  let tkToken, ticketNFT, ticketMaster, event;

  before(async () => {
    tkToken = await TKToken.deployed();
    ticketNFT = await TicketNFT.deployed();
    ticketMaster = await TicketMaster.deployed();
  });

  it("Should create a new organization", async () => {
    await truffleAssert.fails(
      ticketMaster.createOrganization(accounts[2], "Organization Test", {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for owner address"
    );
    await ticketMaster.createOrganization(accounts[1], "Organization Test");
    const organization = await ticketMaster.getOrganization(accounts[1]);
    assert.equal(
      organization.name,
      "Organization Test",
      "Should create a new organization"
    );
  });

  it("Should create a new event", async () => {
    await truffleAssert.fails(
      ticketMaster.createEvent(
        "Event test",
        "Event description",
        new Date().getDate(),
        {
          from: accounts[3],
        }
      ),
      truffleAssert.ErrorType.REVERT,
      "Invalid organization"
    );
    await ticketMaster.createEvent(
      "Event test",
      "Event description",
      new Date().getDate(),
      { from: accounts[1] }
    );
    event = await ticketMaster.getLastEvent({ from: accounts[1] });
    assert.equal(event.name, "Event test", "Should create a new event");
  });

  it("Should create a ticket", async () => {
    const price = web3.utils.toWei("1", "ether");
    await truffleAssert.fails(
      ticketMaster.createTicket(12345, price, {
        from: accounts[3],
      }),
      truffleAssert.ErrorType.REVERT,
      "Invalid organization"
    );
    await ticketMaster.createTicket(event.id, price, { from: accounts[1] });
    const ticket = await ticketMaster.getLastTicket(event.id, {
      from: accounts[1],
    });
    assert.equal(
      ticket.eventId == event.id,
      true,
      "Should create a new ticket for specific event"
    );
  });

  it("Should get organizations IDs", async () => {
    const organizationsIds = await ticketMaster.getOrganizationIds();
    assert.equal(organizationsIds.length, 1, "Should obtain 1 organization");
  });

  it("Should get organization events", async () => {
    await truffleAssert.fails(
      ticketMaster.getOrganizationEvents(12345),
      truffleAssert.ErrorType.REVERT,
      "Organization ID not found"
    );
    const events = await ticketMaster.getOrganizationEvents(
      event.organizationId
    );
    assert.equal(events.length, 1, "Should obtain 1 event");
  });

  it("Should get tickets for an event", async () => {
    await truffleAssert.fails(
      ticketMaster.getEventTickets(12345),
      truffleAssert.ErrorType.REVERT,
      "Event ID not found"
    );
    const tickets = await ticketMaster.getEventTickets(event.id);
    assert.equal(tickets.length, 1, "Should obtain 1 ticket");
  });

  it("Should buy a ticket", async () => {
    const ticket = await ticketMaster.getLastTicket(event.id, {
      from: accounts[1],
    });
    await truffleAssert.fails(
      ticketMaster.buyTicket(12345),
      truffleAssert.ErrorType.REVERT,
      "Invalid ticket Id"
    );
    await truffleAssert.fails(
      ticketMaster.buyTicket(ticket.id, { from: accounts[4] }),
      truffleAssert.ErrorType.REVERT,
      "Insufficient tokens to pay ticket price"
    );
    const buyerInitialTKTBalance = await tkToken.balanceOf(accounts[0]);
    const contractInitialTKTBalance = await tkToken.balanceOf(
      ticketMaster.address
    );
    const organizationInitialTKTBalance = await tkToken.balanceOf(
      ticket.ownerAddress
    );
    await ticketMaster.buyTicket(ticket.id);
    const buyerTKTBalance = await tkToken.balanceOf(accounts[0]);
    const contractTKTBalance = await tkToken.balanceOf(ticketMaster.address);
    const organizationTKTBalance = await tkToken.balanceOf(ticket.ownerAddress);
    assert.equal(
      Number(buyerInitialTKTBalance) > Number(buyerTKTBalance),
      true,
      "Should decrease buyers TKT quantity"
    );
    assert.equal(
      Number(contractInitialTKTBalance) < Number(contractTKTBalance),
      true,
      "Should increase TKT contract comission"
    );
    assert.equal(
      Number(organizationInitialTKTBalance) < Number(organizationTKTBalance),
      true,
      "Should increase TKT organization balance"
    );
    const updatedTicket = await ticketMaster.getTicket(ticket.id);
    assert.equal(
      updatedTicket.ownerAddress == accounts[0],
      true,
      "Should update ticket owner"
    );
    const ticketOwner = await ticketNFT.ownerOf(ticket.id);
    assert.equal(
      ticketOwner == accounts[0],
      true,
      "Should update ticket owner"
    );
    await truffleAssert.fails(
      ticketMaster.buyTicket(ticket.id, { from: accounts[4] }),
      truffleAssert.ErrorType.REVERT,
      "Ticket already sell"
    );
  });
});
