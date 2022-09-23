require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-deploy");
require("hardhat-contract-sizer");
require("dotenv").config();

const ANKR_RPC_URL = process.env.ANKR_RPC_URL;

const POLYGON_PRIVATE_KEY = process.env.POLYGON_PRIVATE_KEY;

const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;

module.exports = {
  solidity: "0.8.7",
  networks: {
    mumbai: {
      url: ANKR_RPC_URL,
      accounts: [POLYGON_PRIVATE_KEY],
      chainId: 80001,
    },
  },
  etherscan: {
    // npx hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    apiKey: {
      polygon: POLYGONSCAN_API_KEY,
    },
  },
};
