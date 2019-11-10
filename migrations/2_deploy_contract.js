const MockFlashLoanReceiver = artifacts.require("MockFlashLoanReceiver");
const MintableERC20 = artifacts.require("MintableERC20");



module.exports = function(deployer) {
  deployer.deploy(MockFlashLoanReceiver, "0x9C6C63aA0cD4557d7aE6D9306C06C093A2e35408")
  // deployer.deploy(MintableERC20)
  //  deployer.deploy(UniswapExchange)
};