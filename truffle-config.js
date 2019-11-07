require('babel-register');
require('babel-polyfill');
const HDWalletProvider = require("@truffle/hdwallet-provider");
const mnemonic = "steel visa urban item define dish solution away shy plunge picnic solve";


module.exports = {
  networks: {
    kovan: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://kovan.infura.io/v3/1ddb66c75f444419a07d200a61de7ef5")
      },
      network_id: 42
    }   
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 2002
      }
    }
  }
}
