require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

const { SIGNER_PRIVATE_KEY, ETH_SCAN_API_KEY, ETH_GOERLI_TESTNET_RPC } =
  process.env;

module.exports = {
  api_keys: {
    etherscan: ETH_SCAN_API_KEY,
  },
  networks: {
    goerli: {
      provider: () =>
        new HDWalletProvider(SIGNER_PRIVATE_KEY, ETH_GOERLI_TESTNET_RPC),
      network_id: 5,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.19",
    },
  },
};
