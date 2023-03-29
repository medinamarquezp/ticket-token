const truffleAssert = require("truffle-assertions");
const TicketMaster = artifacts.require("TicketMaster");

contract("TicketNFT tests", (accounts) => {
  let ticketMaster, event;

  before(async () => {
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
});
