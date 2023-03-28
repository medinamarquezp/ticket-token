const truffleAssert = require("truffle-assertions");
const TicketNFT = artifacts.require("TicketNFT");
const TicketMaster = artifacts.require("TicketMaster");

contract("TicketNFT tests", (accounts) => {
  let ticketNFT, ticketMaster;

  before(async () => {
    ticketNFT = await TicketNFT.deployed();
    ticketMaster = await TicketMaster.deployed();
  });

  const createTicket = async (from = accounts[1]) => {
    const data = { from };
    await ticketMaster.createOrganization(from, "Organization Test");
    await ticketMaster.createEvent(
      "Event test",
      "Event description",
      new Date().getDate(),
      data
    );
    const createdEvent = await ticketMaster.getLastEvent(data);
    await ticketMaster.createTicket(createdEvent.id, data);
    return await ticketMaster.getLastTicket(createdEvent.id, data);
  };

  it("Should set base URI", async () => {
    await truffleAssert.fails(
      ticketNFT.setBaseURI("http://baseuri.com", {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for owner address"
    );
    await ticketNFT.setBaseURI("http://baseuri.com");
    const baseUri = await ticketNFT.baseURI();
    assert.equal(baseUri, "http://baseuri.com", "Should set base URI");
  });

  it("Should authorize an address", async () => {
    await truffleAssert.fails(
      ticketNFT.authorize(accounts[1], true, {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for owner address"
    );
    await ticketNFT.authorize(accounts[1], true);
    const isAuthorized = await ticketNFT.authorized(accounts[1]);
    assert.equal(isAuthorized, true, "Should authorize an address");
  });

  it("Should mint a new ticket", async () => {
    const from = accounts[1];
    const ticket = await createTicket(from);
    await truffleAssert.fails(
      ticketNFT.mintTicket(ticket, {
        from: accounts[2],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for authorized addresses"
    );
    await ticketNFT.mintTicket(ticket);
    const owner = await ticketNFT.ownerOf(ticket.id);
    assert.equal(owner, from, "Should mint a new ticket");
  });
});
