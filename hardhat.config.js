require("@nomicfoundation/hardhat-toolbox");

const DEPLOY_PRIVATE_KEY = "";
const ETHERSCAN_API_KEY="";
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  settings: {
    optimizer: {
      enabled: true,
      runs: 6000,
    },
  },
  defaultNetwork:"rinkeby",
  networks: {
    hardhat: {
    },
    localhost: {
      url: "http://127.0.0.1:7545",
      chainId: 1337,
      gasPrice: 20000000000,
      accounts: [DEPLOY_PRIVATE_KEY]
    },
    bscTest: {
      url: "https://bsctestapi.terminet.io/rpc",
      // url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      // url: "https://nd-344-945-953.p2pify.com/7d3c1ea20da2285ce1a5ca372f80661b",
      // url: "https://bsc.getblock.io/testnet/?api_key=e5c9c491-7a2f-4978-9cc7-81d536d5b755",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [DEPLOY_PRIVATE_KEY]
    },
    kovan: {
      url: "https://kovan.infura.io/v3/8022d14d482249ab8414d6e0811e205e",
      chainId: 42,
      gasPrice: 8000000000,
      gas: 2100000,
      accounts: [DEPLOY_PRIVATE_KEY]
    },
    rinkeby: {
      // url: `https://rinkeby.infura.io/v3/2820b69f6e3a4af3817000efafbc0667`,
      url: `https://rpc.ankr.com/eth_rinkeby`,
      accounts: [DEPLOY_PRIVATE_KEY]
    },
    
  },
  etherscan: {
    apiKey: {
      rinkeby: "ZFRM9Q3CEDS6T6SYWKCYB2JXJMBSGF8DTD",
      bscTestnet:ETHERSCAN_API_KEY
    } 
  }
};
