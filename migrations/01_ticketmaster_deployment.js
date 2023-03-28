const TKToken = artifacts.require("TKToken");
const TicketNFT = artifacts.require("TicketNFT");
const TicketMaster = artifacts.require("TicketMaster");

module.exports = async function (deployer) {
  // ERC20 token deployment
  await deployer.deploy(TKToken);
  const tkToken = await TKToken.deployed();
  // ERC721 token deployment
  await deployer.deploy(TicketNFT);
  const ticketNFT = await TicketNFT.deployed();
  // Main contract deployment
  await deployer.deploy(TicketMaster, tkToken.address, ticketNFT.address);
  const ticketmaster = await TicketMaster.deployed();
  // Authorize ticketmaster address
  await ticketNFT.authorize(ticketmaster.address, true);
};
