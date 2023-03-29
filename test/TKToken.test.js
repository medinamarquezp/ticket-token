const truffleAssert = require("truffle-assertions");
const TKToken = artifacts.require("TKToken");

contract("TKToken tests", (accounts) => {
  let token;

  before(async () => {
    token = await TKToken.deployed();
  });

  it("Should buy tokens", async () => {
    const from = accounts[1];
    await truffleAssert.fails(
      token.buyTokens(),
      truffleAssert.ErrorType.REVERT,
      "Funds required"
    );
    await token.buyTokens({
      from,
      value: web3.utils.toWei("0.1", "ether"),
    });
    const balance = await token.balanceOf(from);
    assert.equal(
      web3.utils.fromWei(balance.toString(), "ether"),
      "1",
      "Should update from tokens balance"
    );
    const contractBalance = await web3.eth.getBalance(token.address);
    assert.equal(
      web3.utils.fromWei(contractBalance.toString(), "ether"),
      "0.1",
      "Should update contract tokens balance"
    );
  });
});
