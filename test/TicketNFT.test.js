const truffleAssert = require("truffle-assertions");
const TicketNFT = artifacts.require("TicketNFT");

contract("TicketNFT tests", (accounts) => {
  let instance;

  before(async () => {
    instance = await TicketNFT.deployed();
  });

  it("Should set base URI", async () => {
    await truffleAssert.fails(
      instance.setBaseURI("http://baseuri.com", {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for owner address"
    );
    await instance.setBaseURI("http://baseuri.com");
    const baseUri = await instance.baseURI();
    assert.equal(baseUri, "http://baseuri.com", "Should set base URI");
  });

  it("Should authorize an address", async () => {
    await truffleAssert.fails(
      instance.authorize(accounts[1], true, {
        from: accounts[1],
      }),
      truffleAssert.ErrorType.REVERT,
      "This operation is only available for owner address"
    );
    await instance.authorize(accounts[1], true);
    const isAuthorized = await instance.authorized(accounts[1]);
    assert.equal(isAuthorized, true, "Should authorize an address");
  });
});
