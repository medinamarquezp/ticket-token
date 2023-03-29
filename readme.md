# 🎟️ Ticket Token

## Prerequisites

- Node JS installed: https://nodejs.org/en/download/
- Truffle suite installed: https://trufflesuite.com/docs/truffle/how-to/install/

## Testnet network

### Ethereum Goerli (testnet) information

- **Network:** Ethereum Goerli
- **New RPC URL:** https://goerli.infura.io/v3/
- **Chain ID:** 5
- **Currency symbol:** ETH
- **Block explorer:** https://goerli.etherscan.io/
- **Faucet:** https://goerlifaucet.com/

## Truffle

#### Deployment

- Copy .env.example and rename it to .env
- Set required variables on .env file

```sh
truffle compile
truffle migrate --network goerli
```

#### Test

Tests all available operations on the contract.

```sh
truffle test
```
