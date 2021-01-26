const randomness = artifacts.require("RandomNumberConsumer");
const lottery = artifacts.require("Lottery");
const governance = artifacts.require("Governance");

module.exports = async function(deployer, network, accounts) {

  var governanceContract = await governance.deployed();
  console.log('governanceContract fetched :', governanceContract.address);

  var lotteryContract = await lottery.deployed();
  console.log('lotteryContract fetched    :', lotteryContract.address);

  var randomnessContract = await randomness.deployed();
  console.log('randomnessContract fetched :', randomnessContract.address);

  console.log("Starting lottery ...");
  await lotteryContract.start_new_lottery(90);
  console.log("Done");
};
