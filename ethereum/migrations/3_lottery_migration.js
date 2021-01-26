const Lottery    = artifacts.require("Lottery");
const Governance = artifacts.require("Governance");

const LinkToken  = artifacts.require("LinkToken_v0.6/LinkToken");

const truffle_config = require('../truffle-config.js');

module.exports = async function (deployer, network, accounts) {

  const network_config = truffle_config.networks[network];

  console.log("network_config =", network_config);

  // const linkAddress = (network_config.linkAddress !== undefined) ? network_config.linkAddress : '0x0';

  // use provided LINK address if defined for network
  if (network_config.linkAddress !== undefined) {
    linkAddress = network_config.linkAddress
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

  await deployer.deploy(Lottery, governanceContract.address, linkAddress);
};
