const Governance = artifacts.require("Governance");
const RandomNumberConsumer = artifacts.require("RandomNumberConsumer");
const Lottery = artifacts.require("Lottery");

module.exports = async function(deployer, network, accounts) {
  var governanceContract = await Governance.deployed();
  var randomNumberConsumerContract = await RandomNumberConsumer.deployed();
  var lotteryContract = await Lottery.deployed();

  await governanceContract.init(
    lotteryContract.address,
    randomNumberConsumerContract.address
  );
};
