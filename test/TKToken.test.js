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
  it("Should sell tokens", async () => {
    const from = accounts[1];
    const initBalanceETH = await web3.eth.getBalance(from);
    await truffleAssert.fails(
      token.sellTokens(web3.utils.toWei("1000", "ether")),
      truffleAssert.ErrorType.REVERT,
      "Insufficient tokens to sell"
    );
    await token.sellTokens(web3.utils.toWei("1", "ether"), { from });
    const balanceTKT = await token.balanceOf(from);
    assert.equal(balanceTKT.toString(), "0", "Should update from TKT balance");
    const balanceETH = await web3.eth.getBalance(from);
    assert.equal(
      balanceETH > initBalanceETH,
      true,
      "Should increase ETH balance"
    );
    const contractETHBalance = await web3.eth.getBalance(token.address);
    assert.equal(
      contractETHBalance.toString(),
      "0",
      "Should update contract ETH balance"
    );
    const contractTKTBalance = await token.balanceOf(token.address);
    assert.equal(
      contractTKTBalance.toString(),
      web3.utils.toWei("10000000", "ether").toString(),
      "Should reset contract TKT balance"
    );
  });
});
