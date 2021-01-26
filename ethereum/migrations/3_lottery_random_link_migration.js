const Lottery    = artifacts.require("Lottery");
const RandomNumberConsumer = artifacts.require("RandomNumberConsumer");
const Governance = artifacts.require("Governance");

const LinkToken  = artifacts.require("LinkToken_v0.6/LinkToken");

const truffle_config = require('../truffle-config.js');

module.exports = async function (deployer, network, accounts) {

  const network_config = truffle_config.networks[network];

  console.log("network_config =", network_config);

  // const linkAddress = (network_config.linkAddress !== undefined) ? network_config.linkAddress : '0x0';

  // use provided LINK address if defined for network
  if (network_config.LINK !== undefined) {
    linkAddress = network_config.LINK
  }
  else if (network.startsWith('main') || network.startsWith('live')) {
    linkAddress = "0x0";  // will cause the contract to retrieve live address
  } else {
    // must be local / development network so we deploy a LINK token
    await deployer.deploy(LinkToken);
    var linkTokenContract = await LinkToken.deployed();
    linkAddress = linkTokenContract.address;
  }

  console.log("using LINK contract address :", linkAddress);

  var governanceContract = await Governance.deployed();

  await deployer.deploy(Lottery,
    governanceContract.address,
    linkAddress,
    network_config.ALARM_ORACLE,
    network_config.ALARM_JOB_ID,
    network_config.ALARM_FEE,
  );


  await deployer.deploy(RandomNumberConsumer,
    governanceContract.address,
    network_config.VRF_KEYHASH,
    network_config.VRF_FEE,
    network_config.VRF_COORDINATOR,
    linkAddress,
  );

};
