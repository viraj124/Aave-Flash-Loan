const MockFlashLoanReceiver = artifacts.require("MockFlashLoanReceiver");
const MintableERC20 = artifacts.require("MintableERC20");


module.exports = function(deployer) {
  deployer.deploy(MockFlashLoanReceiver)
  .then(() => MockFlashLoanReceiver.deployed())
  .then(() => deployer.deploy(MintableERC20))
};